package ongi.maum_log.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum Emotion {
    JOYFUL("즐거움"),
    EXCITED("설렘"),
    RELIEVED("마음이 놓임"),
    SMIRK("뿌듯함"),
    SADNESS("서글픔"),
    STIFLED("답답함"),
    WARMHEARTED("마음이 따뜻"),
    EMPTY("허전함"),
    REFRESHING("시원섭섭함"),
    THRILL("들뜸"),
    ANNOYED("짜증남"),
    SORROWFUL("서운함"),
    WORRIED("걱정스러움"),
    MISSING("그리움"),
    DEPRESSED("울적함"),
    RELAXED("여유로움"),
    CONFUSED("마음이 복잡함"),
    CHEERFUL("기운이 남"),
    COZY("포근함");

    private final String description;
}
