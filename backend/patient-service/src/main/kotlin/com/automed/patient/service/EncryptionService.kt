package com.automed.patient.service

import org.springframework.stereotype.Service
import org.springframework.beans.factory.annotation.Value
import java.security.SecureRandom
import java.util.Base64
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec

@Service
class EncryptionService {

    @Value("\${app.security.encryption.key:}")
    private lateinit var encryptionKey: String

    @Value("\${app.security.encryption.algorithm:AES/GCM/NoPadding}")
    private lateinit var algorithm: String

    private lateinit var secretKey: SecretKey
    private val keySize = 256
    private val ivSize = 12
    private val tagLength = 128

    init {
        initializeKey()
    }

    private fun initializeKey() {
        if (encryptionKey.isBlank()) {
            // Generate a new key if not provided
            val keyGen = KeyGenerator.getInstance("AES")
            keyGen.init(keySize, SecureRandom())
            secretKey = keyGen.generateKey()
            encryptionKey = Base64.getEncoder().encodeToString(secretKey.encoded)
        } else {
            // Use provided key
            val decodedKey = Base64.getDecoder().decode(encryptionKey)
            secretKey = SecretKeySpec(decodedKey, 0, decodedKey.size, "AES")
        }
    }

    fun encrypt(data: String): String {
        val cipher = Cipher.getInstance(algorithm)
        val iv = ByteArray(ivSize).apply { SecureRandom().nextBytes(this) }
        val gcmSpec = GCMParameterSpec(tagLength, iv)

        cipher.init(Cipher.ENCRYPT_MODE, secretKey, gcmSpec)

        val encryptedBytes = cipher.doFinal(data.toByteArray(Charsets.UTF_8))

        // Combine IV and encrypted data
        val combined = ByteArray(iv.size + encryptedBytes.size)
        System.arraycopy(iv, 0, combined, 0, iv.size)
        System.arraycopy(encryptedBytes, 0, combined, iv.size, encryptedBytes.size)

        return Base64.getEncoder().encodeToString(combined)
    }

    fun decrypt(encryptedData: String): String {
        val combined = Base64.getDecoder().decode(encryptedData)
        val iv = combined.copyOfRange(0, ivSize)
        val encryptedBytes = combined.copyOfRange(ivSize, combined.size)

        val cipher = Cipher.getInstance(algorithm)
        val gcmSpec = GCMParameterSpec(tagLength, iv)

        cipher.init(Cipher.DECRYPT_MODE, secretKey, gcmSpec)

        val decryptedBytes = cipher.doFinal(encryptedBytes)
        return String(decryptedBytes, Charsets.UTF_8)
    }

    fun hashData(data: String): String {
        val digest = java.security.MessageDigest.getInstance("SHA-256")
        val hashBytes = digest.digest(data.toByteArray(Charsets.UTF_8))
        return Base64.getEncoder().encodeToString(hashBytes)
    }

    fun generateSecureToken(length: Int = 32): String {
        val bytes = ByteArray(length)
        SecureRandom().nextBytes(bytes)
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes)
    }

    fun encryptBatch(dataList: List<String>): List<String> {
        return dataList.map { encrypt(it) }
    }

    fun decryptBatch(encryptedDataList: List<String>): List<String> {
        return encryptedDataList.map { decrypt(it) }
    }

    // For GDPR compliance - irreversible anonymization
    fun anonymizeData(data: String): String {
        return hashData(data + generateSecureToken(16))
    }

    // Check if data is encrypted (simple check)
    fun isEncrypted(data: String): Boolean {
        return try {
            Base64.getDecoder().decode(data)
            data.length > 50 // Rough check for encrypted data
        } catch (e: Exception) {
            false
        }
    }

    // Get encryption key info (for monitoring, not the actual key)
    fun getEncryptionInfo(): Map<String, Any> {
        return mapOf(
            "algorithm" to algorithm,
            "keySize" to keySize,
            "ivSize" to ivSize,
            "tagLength" to tagLength,
            "keyInitialized" to ::secretKey.isInitialized
        )
    }
}