package com.automed.imaging.service

import com.automed.imaging.dto.ImageUploadRequest
import com.automed.imaging.dto.UploadStatus
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNotNull
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles

@SpringBootTest
@ActiveProfiles("test")
class ImagingServiceTest {

    @Autowired
    private lateinit var imagingService: ImagingService

    @Test
    fun `should upload image successfully`() {
        // Given
        val request = ImageUploadRequest(
            patientId = "patient123",
            modality = "CT",
            studyDescription = "Chest CT",
            bodyPart = "CHEST"
        )
        val imageData = ByteArray(1024) // Mock image data

        // When
        val response = imagingService.uploadImage(imageData, request)

        // Then
        assertEquals(UploadStatus.SUCCESS, response.status)
        assertNotNull(response.imageId)
        assertNotNull(response.message)
    }

    @Test
    fun `should analyze image and return AI results`() {
        // Given
        val imageId = "test-image-123"

        // When
        val response = imagingService.analyzeImage(imageId)

        // Then
        assertNotNull(response)
        assertEquals(imageId, response.imageId)
        assertNotNull(response.analysis)
        assertNotNull(response.modelVersion)
    }
}