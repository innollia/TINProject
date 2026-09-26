# Generator Fidelity Diagnostic — Reference-Preserving Edit Chain

상태: **diagnostic only — Style Master bootstrap에서 분리**

목적: 현재 생성기가 원본 레퍼런스의 실제 픽셀 문법을 편집에서도 보존할 수 있는지 확인한다. 통과하더라도 자동으로 Style Master를 만드는 단계로 이어지지 않는다.

## 원칙

- fresh generation으로 새 캐릭터를 처음부터 만들지 않는다.
- 첫 단계는 반드시 **원본 이미지 편집**으로 시작한다.
- 한 번에 바꾸는 축을 최소화한다.
- 매 단계에서 화풍 보존이 실패하면 그 결과를 다음 단계 입력으로 쓰지 않는다.
- A/B의 구체 캐릭터 정체성은 최종 Style Master에 남기지 않지만, 첫 진단 단계에서는 스타일 보존 여부를 확인하기 위해 원본 구도와 렌더링 대부분을 의도적으로 유지한다.

## Test A-edit-1 — A 보존 편집

입력 이미지:
- 현재 대화에 다시 첨부된 A 원본

편집 계약:

> Edit the provided image rather than redrawing it from scratch. Preserve the original image's brushwork, edge quality, facial plane construction, line behavior, paint texture, hair-mass rendering, lighting treatment, and overall rendering process as closely as possible. Change only the subject's hair color to near-black and change the dress color family from purple to muted ochre-brown. Keep the pose, composition, facial construction, background, and all rendering characteristics otherwise unchanged. Do not clean up or modernize the painting. Do not turn it into a generic anime illustration.

판정:
- 색만 바뀌고 화풍/붓질/선/명암 구조가 원본 수준으로 남아야 통과.
- 원본보다 매끈해지거나 선·붓질이 GPT식으로 재해석되면 실패.

## Test B-edit-1 — B 보존 편집

입력 이미지:
- 현재 대화에 다시 첨부된 B 원본

편집 계약:

> Edit the provided image rather than redrawing it from scratch. Preserve the original image's exact rendering character: uneven dark structural lines, broken and pressure-varying contours, layered cloth construction, rough painted interior fill, collage-like background layering, and foreground/background density contrast. Change only the hair color to dark brown and replace the green outfit color family with muted charcoal and ochre. Keep pose, composition, facial construction, background structure, and rendering behavior otherwise unchanged. Do not simplify, clean up, or convert it into generic anime concept art.

판정:
- 색만 바뀌고 B의 선·밀도·거친 채색이 그대로 유지돼야 통과.
- 모티프는 이 단계에서 일부 남아도 됨. 목적은 스타일 보존 가능성 확인임.

## Test A-edit-2 — 정체성 분리

A-edit-1이 통과한 경우에만 실행.

편집 계약:

> Keep the rendering style and painting process from the current image unchanged. Change the character identity without changing the visual treatment: alter the hairstyle silhouette, facial proportions, and outfit cut so the subject is clearly a different adult woman. Remove distinctive decorative motifs from the source character. Preserve the same brush scale, edge roughness, facial plane logic, line behavior, and background paint treatment. Do not redraw into a cleaner or more generic style.

목적:
- 원본 캐릭터 정체성을 떼어내도 화풍이 버티는지 확인.

## Test B-edit-2 — 정체성 분리

B-edit-1이 통과한 경우에만 실행.

편집 계약:

> Keep the rendering style and painting process from the current image unchanged. Change the character identity and outfit design so the subject is clearly a different adult woman. Remove the source-specific eye motif, botanical ornaments, and distinctive costume motifs. Preserve the same uneven structural-line behavior, cloth construction density, rough interior paint, silhouette complexity, and layered collage background treatment. Do not redraw into a cleaner or more generic style.

목적:
- B의 구체 모티프를 제거해도 핵심 선/배경 문법이 남는지 확인.

## 판정 이후

- A-edit-1/B-edit-1부터 화풍이 무너지면 현재 생성기는 style-critical production에서 제외한다.
- 편집은 보존되지만 새 피사체 생성은 실패하면, 현재 생성기는 **source-preserving edit 전용**으로만 사용할 수 있다.
- 새 피사체 생성과 편집 모두 원본 수준으로 보존될 때만 Style Master/Gold Standard 논의를 다시 연다.
- 다른 생성기/모델 비교는 `docs/research/visual_reference/STYLE_REFERENCE_TOOL_SURVEY_2026-09-26.md`에서 관리한다.
