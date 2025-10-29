package com.sren.userservice.dto;

import java.util.List;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class EmotionHistoryResponse {
    private Long userId;
    private List<EmotionRecordDto> records;
}
