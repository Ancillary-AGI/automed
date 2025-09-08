package com.automed.consultation.handler

import com.fasterxml.jackson.databind.ObjectMapper
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component
import org.springframework.web.socket.*
import java.util.concurrent.ConcurrentHashMap

@Component
class WebRTCSignalingHandler(
    private val objectMapper: ObjectMapper
) : WebSocketHandler {

    private val logger = LoggerFactory.getLogger(WebRTCSignalingHandler::class.java)
    private val sessions = ConcurrentHashMap<String, MutableSet<WebSocketSession>>()

    override fun afterConnectionEstablished(session: WebSocketSession) {
        val consultationId = extractConsultationId(session)
        if (consultationId != null) {
            sessions.computeIfAbsent(consultationId) { mutableSetOf() }.add(session)
            logger.info("WebSocket connection established for consultation: $consultationId")
        } else {
            session.close(CloseStatus.BAD_DATA.withReason("Invalid consultation ID"))
        }
    }

    override fun handleMessage(session: WebSocketSession, message: WebSocketMessage<*>) {
        try {
            val consultationId = extractConsultationId(session)
            if (consultationId != null) {
                val messageText = message.payload.toString()
                val signalMessage = objectMapper.readValue(messageText, SignalMessage::class.java)
                
                // Broadcast to other participants in the same consultation
                sessions[consultationId]?.forEach { otherSession ->
                    if (otherSession != session && otherSession.isOpen) {
                        try {
                            otherSession.sendMessage(TextMessage(messageText))
                        } catch (e: Exception) {
                            logger.error("Error sending message to session", e)
                        }
                    }
                }
                
                logger.debug("Relayed ${signalMessage.type} message for consultation: $consultationId")
            }
        } catch (e: Exception) {
            logger.error("Error handling WebSocket message", e)
            session.close(CloseStatus.SERVER_ERROR.withReason("Message processing error"))
        }
    }

    override fun handleTransportError(session: WebSocketSession, exception: Throwable) {
        logger.error("WebSocket transport error", exception)
        removeSession(session)
    }

    override fun afterConnectionClosed(session: WebSocketSession, closeStatus: CloseStatus) {
        removeSession(session)
        logger.info("WebSocket connection closed: ${closeStatus.reason}")
    }

    override fun supportsPartialMessages(): Boolean = false

    private fun extractConsultationId(session: WebSocketSession): String? {
        val uri = session.uri
        val path = uri?.path ?: return null
        val segments = path.split("/")
        return if (segments.size >= 4) segments[3] else null
    }

    private fun removeSession(session: WebSocketSession) {
        val consultationId = extractConsultationId(session)
        if (consultationId != null) {
            sessions[consultationId]?.remove(session)
            if (sessions[consultationId]?.isEmpty() == true) {
                sessions.remove(consultationId)
            }
        }
    }

    data class SignalMessage(
        val type: String,
        val data: Any?,
        val from: String?,
        val to: String?
    )
}