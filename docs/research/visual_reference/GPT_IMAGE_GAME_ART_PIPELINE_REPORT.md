# GPT 이미지 기반 게임 아트 제작 보고서

## 1. 범위와 출처

이 문서는 사용자가 제공한 공유 대화의 첫 조사 보고서를 TINProject 제작 규칙에 맞게 정리한 연구 입력이다.

- 공유 대화: https://chatgpt.com/share/6ab6725f-5848-83e9-a304-1d1fd78a6510
- 현행 결정 정본: `PROJECT_DECISIONS.md`, `docs/VISUAL_DIRECTION.md`, `docs/GRILLING_STATE.md`
- A/B 원본과 역할: `docs/research/visual_reference/STYLE_AND_CAMERA_REFERENCE.md`

이 보고서는 원문 사례를 자동 구현 목록으로 만들지 않는다. 실제 제작 권한과 충돌 해결은 정본 문서의 최신 사용자 결정을 따른다.

## 2. 핵심 결론

GPT에게 매번 화풍을 새로 발명하게 하지 않는다. 사람이 시각 규칙과 승인 기준을 만들고 GPT는 그 규칙에 따라 최종 그림을 제작한다. 사람의 역할은 Art Director이며, 생성 결과의 선택·배치·수정 지시·게임 화면 판정을 소유한다.

일관성은 긴 프롬프트 하나가 아니라 다음 묶음으로 만든다.

1. 여러 프로젝트에서 재사용하는 개인 화풍 코어
2. 세계관·캐릭터·카메라·UI를 소유하는 프로젝트 아트 층
3. 자산군별 제작 brief
4. 사용자 승인 Gold Standard
5. 실제 게임 화면에서의 검수와 기계적 정규화

## 3. Art Bible과 Gold Standard

Art Bible은 1–3쪽 안에서 다음을 명시하는 것이 유효하다.

- 색 관계와 명도 범위
- 형태 언어와 비례
- 카메라와 원근
- 구조선, 명암, 재질, 세부 밀도
- UI 렌더 문법
- 금지 요소

Gold Standard는 승인된 대표 이미지다. 보고서의 일반 제안은 6–12장이지만 TIN은 전역 한 묶음으로 고정하지 않는다. 환경/배경, 게임플레이 스프라이트, UI, 리깅용 전신 파츠, 비주얼노벨 전신·초상, 조사 화면으로 나누고 프로젝트에 필요한 묶음만 사용한다.

생성 대화가 길어져도 기억 자체를 정본으로 보지 않는다. 필요한 코어, 프로젝트 층, 자산군 Gold Standard를 작업 입력에 다시 제공해야 스타일 표류를 줄일 수 있다.

## 4. 제작 단위

캐릭터와 세계 Bible은 한 장 안에 여러 시점, 얼굴, 표정, 손, 무기, 재질, 팔레트, 소품을 모아 관계를 확인하는 용도로 유효하다.

대량 자산은 자산군별로 분리한다. 캐릭터, 적, 소품, 환경, UI의 요구 조건과 실패 형태가 다르므로 하나의 누적 대화 문맥에 모두 맡기지 않는다.

애니메이션 스프라이트는 완성 시트를 한 번에 생성하면 반복 포즈와 해부 구조가 무너지기 쉽다. 기준 프레임과 포즈 자료를 유지하며 프레임 단위로 제작하는 방향을 우선 검토한다. 리깅용 파츠는 서로 맞물리는 비례와 가려진 면의 여유가 필요하므로 별도 자산군 계약이 필요하다.

## 5. 편집과 정규화

새로 만들기보다 승인된 기준 이미지를 편집하는 편이 정체성 유지에 유리하다. 정체성과 구도가 맞는 오류는 국소 편집, 전체 시각 문법이 틀린 오류는 재생성으로 처리한다.

TIN에서 허용하는 기계적 후처리는 다음과 같다.

- 투명화와 배경 분리
- 크롭
- 캔버스와 피벗 정렬
- 레이어 분리
- 리사이즈
- 아틀라스 패킹
- 색 프로파일 변환
- 결정론적 알파 매트와 가장자리 정리

팔레트 관계, 선 굵기, 캔버스 크기, 캐릭터 높이, 피벗, 투명도, 그림자 방향, 세부 밀도는 자산군 기준으로 정규화한다. 수동 재작화나 자산별 색칠 보정으로 생성 실패를 감추지 않는다.

## 6. 게임 화면 판정

개별 이미지가 아름다운지만 보지 않는다. 실제 플레이 화면에서 다음을 확인한다.

- 플레이 정보가 장식보다 먼저 읽히는가
- 캐릭터, 배경, UI의 밀도와 초점이 충돌하지 않는가
- Primary Reference의 카메라와 화면 문법을 해치지 않는가
- 입력 상태와 focus가 명확한가
- 1280×720, 1920×1080, 2560×1440에서 읽히는가

깊은 프로토타입은 한 구간을 완성도 있게 만들어 파이프라인을 검증하고, 넓은 프로토타입은 여러 자산군과 장면에서 규칙의 확장성을 확인하는 데 쓴다.

## 7. 독창성과 사람의 저작 기여

독창성은 여러 게임의 외형을 평균내는 데서 만들지 않는다. 게임 밖의 서로 다른 참고 자료, 사용자 스케치, 구체적인 세계 설정을 시각 규칙으로 번역하고 사람이 선택·배치·수정한다.

공유 보고서는 미국 저작권청의 2025년 자료를 근거로 프롬프트만으로 결정된 표현보다 사람의 선택·배열·수정이 중요하다고 요약했다. 이는 미국 기준의 연구 참고이며 법률 판단 문서가 아니다. Steam 출시를 준비할 때는 콘텐츠 설문에서 사전 생성 AI 콘텐츠를 공개하고 사용 권리를 개발자가 확인해야 한다는 보고서의 지적을 반영한다.

## 8. 프로젝트 적용

공유 보고서의 일반론을 TIN에 그대로 복사하지 않고 다음처럼 적용한다.

- 개인 화풍 코어와 프로젝트 아트 층을 분리한다.
- A/B는 제한된 역할의 영구 Style Reference로 둔다.
- Gold Standard는 자산군별로 둔다.
- 배경 정보 중요도는 `증거·직접 상호작용`, `길찾기·상황 이해`, `분위기`로 brief에 명시한다.
- GPT 출력은 최종 그림이며 허용된 기계적 후처리만 적용한다.
- 실제 게임 화면에서 최종 승인한다.

## 9. 2026-09-26 추가 조사 — 생성 경계에서 생기는 정보 손실

이번 재조사는 현재 OpenAI 공식 가이드와 최근 실무 사례를 기준으로 했다.

### 긴 정본과 긴 생성 프롬프트는 같은 것이 아니다

OpenAI Academy의 2026-04-10 이미지 생성 가이드는 좋은 이미지 프롬프트가 길 필요가 없고 많은 경우 **1–3개의 명확한 문장**이면 충분하다고 설명한다. 여러 이미지를 넣을 때도 작은 세트가 관리하기 쉽고, 결과 개선은 큰 재작성보다 작은 표적 수정으로 반복하는 방식을 권한다.

- https://openai.com/academy/image-generation/

TIN 적용:
- Art Bible과 프로젝트 정본은 길어도 된다.
- 정본 전체를 매번 생성 프롬프트로 직렬화하지 않는다.
- 실제 생성에는 Compact Visual Contract와 필요한 이미지 원본만 넣는다.

### reference에는 역할을 주되, 합성된 목표 픽셀도 만든다

OpenAI의 현재 Image Prompting 가이드는 여러 입력을 쓸 때 각 이미지가 subject/style/clothing/background 중 무엇을 통제하는지 명시하라고 한다. 동시에 style transfer 예시는 한 장의 입력을 실제 스타일 기준으로 주고 새 subject를 별도로 설명하는 매우 단순한 형태다.

- https://developers.openai.com/api/docs/guides/image-prompting

TIN 적용:
- A/B의 역할 분리는 유지한다.
- 그러나 production마다 A/B 두 장의 추상적 역할을 다시 합성시키지 않는다.
- A/B를 합성해 사용자가 승인한 Style Master 한 장을 만든 뒤, production에서는 그 픽셀 목표를 우선 사용한다.

### 생성 도구 자체의 prompt rewrite를 독립 변수로 본다

OpenAI의 Image Generation tool 문서는 Responses API의 이미지 생성 도구에서 메인 GPT 모델이 이미지 생성 성능을 높이기 위해 프롬프트를 자동 수정할 수 있고, API에서는 `revised_prompt`를 확인할 수 있다고 설명한다.

- https://developers.openai.com/api/docs/guides/tools-image-generation

따라서 긴 프로젝트 문맥이 이미지 모델에 그대로 전달된다고 가정하지 않는다. 생성 경계는 **lossy compiler**처럼 취급한다.

TIN 적용:
- `revised_prompt`가 노출되는 API/도구에서는 원 요청과 함께 기록한다.
- 노출되지 않는 ChatGPT 표면에서는 핵심 시각 불변식이 rewrite 뒤에도 살아남도록 생성 계약 자체를 짧고 관찰 가능하게 만든다.
- 스타일 실패가 반복되면 "문서를 더 길게"보다 "생성 경계에 실제로 전달될 최소 계약이 무엇인가"를 먼저 검증한다.

### community evidence는 보조로만 사용

2026-05의 r/aigamedev 논의에서도 style guide/reference를 반복 공급하라는 실무 조언과, reference image가 style보다 원본의 구체 요소를 끌고 오는 문제가 동시에 보고됐다. 이는 공식 규칙이 아니라 경험담이지만, A/B의 구체 모티프 유출을 검사해야 하는 이유와 맞는다.

- https://www.reddit.com/r/aigamedev/comments/1tobieh/how_do_you_manage_consistency_and_coherence/

2026-09의 prompt-engineering 커뮤니티 사례도 강한 prompt에서 reference scope와 load-bearing constraint를 제한하고, 긴 exclusion list보다 구체적인 optical description을 쓰는 패턴을 보고했다. 재구성 자료이므로 공식 근거로 승격하지 않는다.

- https://www.reddit.com/r/PromptEngineering/comments/1wcbfjw/i_recovered_the_prompts_behind_openais_own_gpt/

## 10. 2026-09-26 실측 교정 — Gold Standard는 fidelity amplifier가 아님

A-only, B-only, A+B fresh-generation 실험에서 현재 ChatGPT/OpenAI 이미지 경로가 원본 A/B의 그림체를 충분히 유지하지 못했다.

이 결과로 이전 보고서의 적용 순서를 교정한다.

- Gold Standard는 **이미 성공한 생성기의 일관성 유지**에 유효하다.
- Style Master도 **이미 확보된 렌더 문법의 편의 기준**이다.
- 둘 중 어느 것도 원본 레퍼런스를 제대로 해석하지 못하는 생성기의 style-transfer 능력을 만들어 내지 않는다.
- 생성기 자체의 reference fidelity가 먼저 검증되어야 한다.

따라서 TIN의 현재 순서는:

1. Generator Style-Fidelity Gate
2. 통과한 생성기에서 A/B 결합 검증
3. 필요하면 Style Master
4. production 후보
5. 자산군 Gold Standard
6. 실제 게임 화면 검수

현재 도구 비교는 [Style Reference Tool Survey](STYLE_REFERENCE_TOOL_SURVEY_2026-09-26.md)에 기록한다.

## 11. 원 보고서가 제시한 출처

아래 URL은 공유 대화의 첫 조사 보고서에 제시된 문자열을 보존한 것이다. 이 문서를 작성하면서 각 페이지의 현재 내용을 다시 독립 검증한 것은 아니다.

- https://openai.com/academy/image-generation/
- https://openai.com/ko-KR/academy/image-generation/
- https://www.reddit.com/r/gamedev/comments/1w3qttz/how_can_you_make_your_game_theme_assets_and_feel/
- https://www.reddit.com/r/aigamedev/comments/1vqdvaq/my_workflow_for_consistent_sprite_styles/
- https://community.openai.com/t/developing-sprite-sheets-with-gpt-image-2/1379831
- https://www.reddit.com/r/ChatGPT/comments/1u8yybh/gpt_image_2_gave_me_a_full_anime_storyboard_and/
- https://community.openai.com/t/ai-game-studio-dev-log-by-platypus/1397035/3
- https://www.reddit.com/r/aigamedev/comments/1n54flp
- https://www.reddit.com/r/aigamedev/comments/1uooc25/should_i_redo_all_the_art_manually_in_pixel_art/
- https://www.reddit.com/r/comfyui/comments/1wokge5/whats_your_most_reliable_comfyui_approach_for/
- https://copyright.gov/newsnet/2025/1060.html
- https://partner.steamgames.com/doc/gettingstarted/contentsurvey?language=koreana
