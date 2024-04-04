package com.ssafy.coffee.domain.s3.service;

import com.amazonaws.AmazonServiceException;
import com.amazonaws.SdkClientException;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
@Transactional
@RequiredArgsConstructor
public class S3Service {
    private static final Logger logger = LoggerFactory.getLogger(S3Service.class);

    private final AmazonS3 amazonS3Client;

    @Value("${cloud.aws.s3.bucket}")
    private String bucketName;

    public List<String> uploadMultipleFiles(String directory, MultipartFile[] files) {
        List<String> fileUrls = new ArrayList<>();

        for (MultipartFile file : files) {
            String fileUrl = uploadFile(directory, file);
            if (fileUrl != null)
                fileUrls.add(fileUrl);
            else
                logger.error("Failed to upload file: {}", file.getOriginalFilename());
        }

        return fileUrls;
    }

    public String uploadFile(String directory, MultipartFile file) {

        if (file == null) return null;

        String originalFileName = Optional.ofNullable(file.getOriginalFilename()).orElse("unnamed");
        String saveFileName = UUID.randomUUID() + extractExtension(originalFileName);

        String fileKey = directory + "/" + saveFileName;

        try {
            ObjectMetadata metadata = new ObjectMetadata();
            metadata.setContentLength(file.getSize());

            PutObjectRequest putObjectRequest = new PutObjectRequest(bucketName, fileKey, file.getInputStream(), metadata);
            amazonS3Client.putObject(putObjectRequest);

            String fileUrl = amazonS3Client.getUrl(bucketName, fileKey).toString();
            logger.info("File uploaded successfully: {} with URL: {}", saveFileName, fileUrl);

            return fileUrl;
        } catch (AmazonServiceException e) {
            logger.error("Amazon service error: {}", e.getErrorMessage(), e);
            return null;
        } catch (SdkClientException e) {
            logger.error("Amazon SDK client error: {}", e.getMessage(), e);
            return null;
        } catch (IOException e) {
            logger.error("Failed to upload file: {}", originalFileName, e);
            throw new RuntimeException(e);
        }
    }

    private String extractExtension(String fileName) {
        int dotIndex = fileName.lastIndexOf('.');
        return dotIndex != -1 ? fileName.substring(dotIndex) : "";
    }
}
