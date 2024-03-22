package com.ssafy.coffee.domain.global.service;

import com.ssafy.coffee.domain.bean.entity.Bean;
import com.ssafy.coffee.domain.bean.repository.BeanRepository;
import com.ssafy.coffee.domain.global.entity.Global;
import com.ssafy.coffee.domain.global.repository.GlobalRepository;
import com.ssafy.coffee.domain.roasting.entity.Roasting;
import com.ssafy.coffee.domain.roasting.repository.RoastingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class GlobalService {

    private final BeanRepository beanRepository;
    private final RoastingRepository roastingRepository;
    private final GlobalRepository globalRepository;

    public void addBasicData() {
        beanRepository.save(Bean.builder()
                .type("Arabica")
                .content("아라비카는 부드럽고 향기가 있으며, 로브스타종에 비해 단맛, 신맛, 감칠맛, 향이 뛰어나 가격이 더 비싸고, 카페인 함유량이 로부스타보다 적습니다.아라비카종은 해발 900~2000m 이상의 고지대에서 생산되며, 기계를 이용한 대량 재배와 수확이 불가능하기 때문에 사람손으로 일일이 심고 가꾸고 거두어야 합니다.")
                .image("https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/bean/1/e3a8bbac-10cd-4ba7-9199-a9180bc58183.png")
                .build());
        beanRepository.save(Bean.builder()
                .type("Robusta")
                .content("로부스타의 원산지는 아프리카 콩고로써 평지에서 기계로 재배하기 때문에 콩이 여문 정도나 크기, 결손 원두를 가리지 않고 모두 한꺼번에 가공합니다." +
                        "또한 30도 이상의 온도에 7-8일 정도 견딜 수 있어 아라비카 종보다 기생충과 질병에 대한 저항력이 강하고, 해발고도 800m이하의 낮은 고도에서 생산이 가능하며 기후변화나 다른 토양등 환경적인 변화에 잘 견디는 특징이 있습니다.")
                .image("https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/bean/2/d07bf362-c812-4238-957a-0bf9ae4a77c1.png")
                .build());
        beanRepository.save(Bean.builder()
                .type("Liberica")
                .content("리베리카는 아프리카의 리베리아가 원산지인데 쓴맛이 강하고 향이 적어 전체 약1% 수준으로 생산량이 적습니다.")
                .image("https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/bean/3/ee3e0ac0-d69b-47ae-b4b2-2454b98afe5a.png")
                .build());


        roastingRepository.save(Roasting.builder()
                .type("Light")
                .content("이 단계의 원두를 가지고 커피를 추출하면 커피 본래의 맛을 느끼기 어렵습니다. " +
                        "생두의 수분이 빠져나가기 시작하는 초기 단계입니다.")
                .image("https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/roasting/1/4337344b-be6f-4b62-bbfc-0d3e2f769ebf.PNG")
                .build());
        roastingRepository.save(Roasting.builder()
                .type("Cinnamon")
                .content("신맛이 잘 살아나는 단계로,커피의 좋은 신맛을 즐기고 싶은 사람들에게 적합합니다. " +
                        "생두의 외피(silver skin)가 왕성하게 제거되기 시작하는 시점입니다.")
                .image("https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/roasting/2/af9a6974-79a3-425f-9ba4-0ff60926753e.PNG")
                .build());
        roastingRepository.save(Roasting.builder()
                .type("Medium")
                .content("신맛이 강하고 쓴맛이 살짝 가미된 커피를 만들기에 좋은 로스팅 레벨로 " +
                        "빠르고 쉽게 추출해서 편하게 마시기 좋은 초기 단계의 커피입니다.")
                .image("https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/roasting/3/9dd9ea91-7811-452d-a54a-7b06c2174967.PNG")
                .build());
        roastingRepository.save(Roasting.builder()
                .type("High")
                .content("신맛이 엷어 지면서 단맛이 나기 시작합니다. " +
                        "부드러우면서도 신맛과 단맛이 우러나오는 레귤러 커피로 즐기기에 좋습니다.")
                .image("https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/roasting/4/2cf1b6a7-d251-4601-b942-254fdf64f73a.PNG")
                .build());
        roastingRepository.save(Roasting.builder()
                .type("City")
                .content("균형 잡힌 맛과 강한 느낌의 향미가 느껴지는 레벨로 " +
                        "맛과 향에 있어 무난한 균형미를 추구 할 때 많이 사용합니다.")
                .image("https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/roasting/5/a7a58326-6ea4-49ab-b388-0a0fec793302.PNG")
                .build());
        roastingRepository.save(Roasting.builder()
                .type("Full City")
                .content("신맛은 거의 없어지고 쓴맛과 진한 맛이 살아나면서 " +
                        "커피 고유의 맛이 강조되는 단계입니다.")
                .image("https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/roasting/6/8f5ac5ae-6bdf-43e7-9035-c8a0a56bc418.PNG")
                .build());
        roastingRepository.save(Roasting.builder()
                .type("French")
                .content("검은 흑갈색으로 표면에 기름기가 돌기 시작합니다. " +
                        "쓴맛이 더욱 진해지면서 진한 커피맛과 중후한 뒷맛이 강조됩니다.")
                .image("https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/roasting/7/41c3eb4b-8391-4257-a733-596b33418443.PNG")
                .build());
        roastingRepository.save(Roasting.builder()
                .type("Italian")
                .content("쓴맛과 진한 맛이 정점에 달하는 로스팅 레벨로 " +
                        "생두의 종류에 따라서는 타는 냄새가 나는 경우도 있으며, 로스팅 타임도 매우 짧습니다.")
                .image("https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/roasting/8/d80d8824-0de5-447e-934b-3c31ec4a982e.PNG")
                .build());


        globalRepository.save(Global.builder()
                .key("global_nomal_bean")
                .value(0L)
                .build());
        globalRepository.save(Global.builder()
                .key("global_flaw_bean")
                .value(0L)
                .build());

    }
}
