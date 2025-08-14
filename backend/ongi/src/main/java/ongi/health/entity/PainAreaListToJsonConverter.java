package ongi.health.entity;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import java.util.List;

@Converter
public class PainAreaListToJsonConverter implements AttributeConverter<List<PainRecord.PainArea>, String> {
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public String convertToDatabaseColumn(List<PainRecord.PainArea> painAreas) {
        try {
            return objectMapper.writeValueAsString(painAreas);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Error converting pain areas to JSON", e);
        }
    }

    @Override
    public List<PainRecord.PainArea> convertToEntityAttribute(String json) {
        try {
            if (json == null || json.isEmpty()) {
                return List.of();
            }
            
            // 기존 단일 값 데이터 처리 (예: "LEFT_SHOULDER")
            if (!json.startsWith("[")) {
                try {
                    PainRecord.PainArea singleArea = PainRecord.PainArea.valueOf(json);
                    return List.of(singleArea);
                } catch (IllegalArgumentException e) {
                    // 기존 데이터가 유효하지 않은 경우 빈 리스트 반환
                    return List.of();
                }
            }
            
            // 새로운 JSON 배열 데이터 처리
            return objectMapper.readValue(json, new TypeReference<List<PainRecord.PainArea>>() {});
        } catch (JsonProcessingException e) {
            // JSON 파싱 실패 시 빈 리스트 반환
            return List.of();
        }
    }
} 