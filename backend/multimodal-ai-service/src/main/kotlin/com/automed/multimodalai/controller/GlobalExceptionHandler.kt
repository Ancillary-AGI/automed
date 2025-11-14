package com.automed.multimodalai.controller

import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.access.AccessDeniedException
import org.springframework.validation.FieldError
import org.springframework.web.bind.MethodArgumentNotValidException
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice
import org.springframework.web.context.request.WebRequest
import java.time.LocalDateTime

@RestControllerAdvice
class GlobalExceptionHandler {

    private val logger = LoggerFactory.getLogger(GlobalExceptionHandler::class.java)

    @ExceptionHandler(IllegalArgumentException::class)
    fun handleIllegalArgumentException(
        ex: IllegalArgumentException,
        request: WebRequest
    ): ResponseEntity<ErrorResponse> {
        logger.warn("Illegal argument exception: ${ex.message}", ex)
        return ResponseEntity(
            ErrorResponse(
                timestamp = LocalDateTime.now(),
                status = HttpStatus.BAD_REQUEST.value(),
                error = "Bad Request",
                message = ex.message ?: "Invalid request parameters",
                path = request.getDescription(false).replace("uri=", "")
            ),
            HttpStatus.BAD_REQUEST
        )
    }

    @ExceptionHandler(IllegalStateException::class)
    fun handleIllegalStateException(
        ex: IllegalStateException,
        request: WebRequest
    ): ResponseEntity<ErrorResponse> {
        logger.error("Illegal state exception: ${ex.message}", ex)
        return ResponseEntity(
            ErrorResponse(
                timestamp = LocalDateTime.now(),
                status = HttpStatus.INTERNAL_SERVER_ERROR.value(),
                error = "Internal Server Error",
                message = ex.message ?: "Service is in an invalid state",
                path = request.getDescription(false).replace("uri=", "")
            ),
            HttpStatus.INTERNAL_SERVER_ERROR
        )
    }

    @ExceptionHandler(MethodArgumentNotValidException::class)
    fun handleValidationExceptions(
        ex: MethodArgumentNotValidException,
        request: WebRequest
    ): ResponseEntity<ValidationErrorResponse> {
        logger.warn("Validation error: ${ex.message}", ex)

        val errors = ex.bindingResult.allErrors.associate { error ->
            val fieldName = (error as? FieldError)?.field ?: error.objectName
            fieldName to (error.defaultMessage ?: "Invalid value")
        }

        return ResponseEntity(
            ValidationErrorResponse(
                timestamp = LocalDateTime.now(),
                status = HttpStatus.BAD_REQUEST.value(),
                error = "Validation Failed",
                message = "Request validation failed",
                path = request.getDescription(false).replace("uri=", ""),
                validationErrors = errors
            ),
            HttpStatus.BAD_REQUEST
        )
    }

    @ExceptionHandler(AccessDeniedException::class)
    fun handleAccessDeniedException(
        ex: AccessDeniedException,
        request: WebRequest
    ): ResponseEntity<ErrorResponse> {
        logger.warn("Access denied: ${ex.message}", ex)
        return ResponseEntity(
            ErrorResponse(
                timestamp = LocalDateTime.now(),
                status = HttpStatus.FORBIDDEN.value(),
                error = "Forbidden",
                message = "Access denied",
                path = request.getDescription(false).replace("uri=", "")
            ),
            HttpStatus.FORBIDDEN
        )
    }

    @ExceptionHandler(MultimodalProcessingException::class)
    fun handleMultimodalProcessingException(
        ex: MultimodalProcessingException,
        request: WebRequest
    ): ResponseEntity<MultimodalErrorResponse> {
        logger.error("Multimodal processing error: ${ex.message}", ex)
        return ResponseEntity(
            MultimodalErrorResponse(
                timestamp = LocalDateTime.now(),
                status = HttpStatus.UNPROCESSABLE_ENTITY.value(),
                error = "Multimodal Processing Error",
                message = ex.message ?: "Error processing multimodal data",
                path = request.getDescription(false).replace("uri=", ""),
                modality = ex.modality,
                processingStep = ex.processingStep,
                partialResults = ex.partialResults
            ),
            HttpStatus.UNPROCESSABLE_ENTITY
        )
    }

    @ExceptionHandler(ModelLoadingException::class)
    fun handleModelLoadingException(
        ex: ModelLoadingException,
        request: WebRequest
    ): ResponseEntity<ErrorResponse> {
        logger.error("Model loading error: ${ex.message}", ex)
        return ResponseEntity(
            ErrorResponse(
                timestamp = LocalDateTime.now(),
                status = HttpStatus.SERVICE_UNAVAILABLE.value(),
                error = "Service Unavailable",
                message = "AI model loading failed: ${ex.message}",
                path = request.getDescription(false).replace("uri=", "")
            ),
            HttpStatus.SERVICE_UNAVAILABLE
        )
    }

    @ExceptionHandler(Exception::class)
    fun handleGenericException(
        ex: Exception,
        request: WebRequest
    ): ResponseEntity<ErrorResponse> {
        logger.error("Unexpected error: ${ex.message}", ex)
        return ResponseEntity(
            ErrorResponse(
                timestamp = LocalDateTime.now(),
                status = HttpStatus.INTERNAL_SERVER_ERROR.value(),
                error = "Internal Server Error",
                message = "An unexpected error occurred",
                path = request.getDescription(false).replace("uri=", "")
            ),
            HttpStatus.INTERNAL_SERVER_ERROR
        )
    }

    // Error Response DTOs
    data class ErrorResponse(
        val timestamp: LocalDateTime,
        val status: Int,
        val error: String,
        val message: String,
        val path: String
    )

    data class ValidationErrorResponse(
        val timestamp: LocalDateTime,
        val status: Int,
        val error: String,
        val message: String,
        val path: String,
        val validationErrors: Map<String, String>
    )

    data class MultimodalErrorResponse(
        val timestamp: LocalDateTime,
        val status: Int,
        val error: String,
        val message: String,
        val path: String,
        val modality: String?,
        val processingStep: String?,
        val partialResults: Map<String, Any>?
    )

    // Custom Exceptions
    class MultimodalProcessingException(
        message: String,
        val modality: String? = null,
        val processingStep: String? = null,
        val partialResults: Map<String, Any>? = null
    ) : RuntimeException(message)

    class ModelLoadingException(message: String) : RuntimeException(message)
}