# descent_exploration audio

W3가 아래 명령으로 13개 `.wav`를 렌더한다. 이 Kit은 wav를 만들지 않는다. 렌더 뒤 `.import`도 함께 커밋한다.

```
nkido render res://modules/descent_exploration/audio/patches/<name>.akkado \
  -o modules/descent_exploration/audio/<name>.wav \
  --seconds 1.2 --rate 48000 --no-default-bank
```

원본 패치: `modules/descent_exploration/audio/patches/<name>.akkado`

13개 이름: `swim surge land pickup denied consume bristle anchor fact hurt downed descend ambience`
