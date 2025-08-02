새로운 flutter 프로젝트 만들어줘. 이름은 filmFit. 이제 내가 만드려는 앱 내용을 말해줄게. 코드는 우선 작성하지마.

# 1. RectangleInput
- [x] 1.1 직사각형의 width, height, 를 mm 기준으로 입력받고, 갯수를 입력받는 UI 가 있으면 좋겠어. 이 컴포넌트의 이름은 RectangleInput 야. 모든 입력은 0 이상의 정수로만 받을 수 있고, 각각의 RectangleInput은 서로 구분할 수 있는 색상을 부여해줘. 해당 컴포넌트에는 - 버튼도 있어서 클릭하는 경우 해당 RectangleInput을 제거하고 싶어.
- [x] 1.2 각각 입력의 초기값은 0 이고, 각각의 입력란을 선택하는 경우 해당 입력란의 전체 텍스트를 선택해줘.
- [x] 1.3 만약 RectangleInput 의 입력이 비어있거나 0 이면 해당 입력을 빨간색으로 표시해줘
- [x] 1.4 색상팔레트는 입력받은 RectangleInput 갯수만큼 색깔로 구분해줘 (Red, Blue, Green, Yellow, Orange, Purple, Pink, Brown, Black, White, Gray, Cyan, Magenta, Lime, Navy, Teal, Maroon, Olive, Gold, Silver, Indigo, Coral, Turquoise, Beige, Mint, Lavender, Peach, Sky Blue, Crimson, Chartreuse)
- [x] 1.5 30개 이상의 RectangleInput 생기면 동일 색상 이용해도돼
- [x] 1.6 width, height, 갯수가 0 인 경우, 아래 '배치' 버튼은 비활성화 되어야해

# 2. RectangleInputList
- [x] 2.1 RectangleInputList 의 우상단에 + 버튼이 있어서, RectangleInput 를 추가할 수 있는 UI 가 있으면 좋겠어. RectangleInput 들은 RectangleInputList 에서 관리하고 싶어.
- [x] 2.2 + 버튼 왼쪽에는 '모두 초기화' 버튼이 있어서, 누르면 빈 RectangleInput 하나만 남기고 RectangleInputList 에 있는 RectangleInput 모두 삭제해줘

# 3. InputView
- [x] 3.1 RectangleInputList 를 배치한 진입화면을 InputView 라고 할게.
- [x] 3.2 RectangleInputList 상단에 '사각형 회전 허용안함' checkbox 를 하나 추가해줘
- [x] 3.3 RectangleInputList 하단에는 '배치' 버튼이 있고, width, height, 갯수 입력이 모두 0 이 아니고 값이 입력된 경우 활성화될거야.

# 4. Board
- [x] 4. '배치' 버튼을 누르면 1번에서 입력받은 RectangleInput들을, 1220mm*50000mm 직사각형 영역안에 겹치지 않게 배치하고 싶어. 이 공간은 Board 라고 할거야.
- [x] 4.1 Board 는 입력화면과는 별도의 화면에서 CustomScrollView 로 만들어주고, CustomScrollView 는 전체화면 width 100% 로 보여줘.
- [x] 4.2 Board 테두리는 검정색으로 해줘
- [x] 4.3 1220mmx50000mm 를 한화면에 보여주면 너무 작으니까, Board 는 세로 스크롤만 가능해야해. 가로 스크롤은 허용하지마
- [x] 4.4 Board 최상단 가운데에는 실제로 사용한 세로길이를 xxxxmm/50000mm 로 표시해줘. 이건 UsedHeight 라고할거야.
- [x] 4.5 Board 우상단에는 '다시 입력하기' 버튼을 추가해서, 누르면 RectangleInputList 화면으로 돌아가고, 입력된 RectangleInput 들은 모두 세션동안만  유지해줘. 앱재시작시에는 유지안해도돼
- [x] 4.6 배치 알고리즘은 아래에서 다시 설명할게. 우선 최소한의 height 를 쓰면서 배치하도록 임의로 구현해도돼

# 5. PlacedRectangle
- [x] 5.1 배치된 사각형은 PlacedRectangle 이라고 할게
- [x] 5.2 PlacedRectangle 는 RectangleInput 의 width, height, color 를 그대로 쓰면 돼
- [x] 5.3 PlacedRectangle 들끼리 잘 구분될 수 있도록 모서리 색상은 약간 진하게 해줘 (RGB 기준 80% )
- [x] 5.4 배치가 완료된 후에는, 사용자가 직접 PlacedRectangle 들을 회전하거나, 이동시킬 수 있어.
- [x] 5.5 PlacedRectangle 은 회전 여부도 가지고 있어야해
- [x] 5.6 PlacedRectangle 의 위치가 변경될때마다 UsedHeight 를 드래그 완료시 업데이트 해줘.
- [x] 5.7 GestureDetector 이용해서 회전과 드래그 앤 드랍 구현해줘
- [x] 5.8 사각형 내부에 크기 정보 표시해줘. 사각형이 너무 작으면 글자도 줄여줘

## 5.1 PlacedRectangle 회전
- [x] 5.1.1 PlacedRectangle 를 짧게 tap 하는 경우는 90도 회전을 시켜줘. 회전되었다는 것을 표시해주기 위해 PlacedRectangle 좌측 상단에 '↻' 인디케이터 표시해줘.
- [x] 5.1.2 PlacedRectangle 을 회전한 경우, Board 를 벗어나거나 다른 PlacedRectangle 영역과 겹치면 회전이 불가하다는 메시지를 이유와 함께 SnackBar로 보여줘

## 5.2 PlacedRectangle 드래그 앤 드랍
- [x] 5.2.1 PlacedRectangle 를 길게 press 하고 있는 경우(0.1초 이상)는 PlacedRectangle를 드래그 앤 드랍 모드로 전환해줘.
- [x] 5.2.2 PlacedRectangle 드래그 앤 드랍 모드에서 손을 떼면 다시 드래그 앤 드랍 아닌 모드로 전환해줘
- [x] 5.2.3 드래그해서 드랍하는 경우 다른 곳에 위치시킬 수 있어
- [x] 5.2.4 드래그 모드에서는 색상을 opacity 0.7로 dim해주고, 드래그하는 동안 사각형이 이동하는 것도 표시해줘. 
- [x] 5.2.5 드래그 모드가 끝나면 색상은 원래대로 되돌려줘
- [x] 5.2.6 드랍하면 PlacedRectangle 를 그 위치에 위치시킬거야. 이 경우 회전은 되면 안돼.
- [x] 5.2.7 PlacedRectangle 를 드래그해서 드랍한 경우 Board 를 벗어나거나 다른 PlacedRectangle 영역과 겹치면 이동이 불가하다는 메시지를 이유와 함께 보여줘
- [x] 5.2.8 PlacedRectangle을 길게 press 하지 않고 스크롤하는 경우는 Board를 스크롤해줘. 다른 사각형들은 회전되거나 이동되면 안돼.

## 5.3 PlacedRectangle 드래그 앤 드랍 스내핑
- [x] 5.3.1 드래그하는 PlacedRectangle이 다른 사각형 모서리나 꼭지점 가까이 가면 그 사각형 모서리나 꼭지점에 snap 시킬거야. snap 되는 기준은 20px 로 할게. 
- [x] 5.3.2 snap 된 PlacedRectangle을 다시 모서리나 꼭지점에서 20px 이상 떨어지게 움직이면 snap 해제되어야해
- [x] 5.3.3 드래그하는 PlacedRectangle 이 Board 근처에 가면 Board 모서리나 꼭지점에 snap 시킬거야. snap 되는 기준은 20px 로 할게. 
- [x] 5.3.4 snap 된 PlacedRectangle을 다시 Board 모서리나 꼭지점에서 20px 이상 떨어지게 움직이면 snap 해제되어야해
- [x] 스내핑할때는 꼭지점이 모서리보다 우선이야. 가장 가까운 거리 우선으로 스내핑해줘

# 6. 배치 로직
- [x] 6.1. '사각형 회전 허용안함' checkbox 가 체크된 경우는 만약 체크된 경우라면, RectangleInput을 '배치' 할때 사각형의 orientation 을 변경하지 않고 배치해야해. RectangleInput 에 입력받은 갯수만큼 배치해주고.
- [x] 6.2  '사각형 회전 허용안함' checkbox 가 체크되지 않은 경우라면 직사각형의 orientation 을 변경해서 배치해봐도 돼. Bottom-Left Fill 알고리즘으로 구현해줘. https://www.csc.liv.ac.uk/~epa/surveyhtml.html 참고해줘
- [x] 6.3 세로 공간(50000mm)을 최소한으로 사용해서 배치해야해. 
- [x] 6.4 가로 공간(1220mm) 는 더 이상 늘어날 수 없어.
- [x] 6.5 세로 공간(50000mm)은 늘어날 수 있는데, 만약 50000mm 안에 모두 배치하지 못하면 50000mm 위치에 빨간색 실선으로 표시하고, Board 를 필요한만큼 더 늘려서 배치해줘. 배치 알고리즘 실행시 한번에 늘려줘
- [x] 6.6 세로 공간은 한계는 없어.
- [x] 6.7 매우 큰 사각형이 배치되어야 하면 1220mm x 80000mm Board 를 늘려줘

# 7. 시각적 표시 및 라인
- [x] 7.1 Board 최상단에 'Used Height: XXXmm / 50000mm' 형태로 사용된 높이 정보를 표시해줘
- [x] 7.2 실제 사용된 높이(가장 아래 PlacedRectangle 라인)에 파란색 점선을 그려줘
- [x] 7.3 파란색 점선 아래쪽에 'Used: XXXmm' 라벨을 파란 배경으로 표시해줘
- [x] 7.4 Board가 50000mm를 초과한 경우, 50000mm 위치에 빨간색 실선을 그려줘
- [x] 7.5 빨간색 실선 위쪽에 '50000mm (Original Limit)' 라벨을 빨간 배경으로 표시해줘
- [x] 7.6 점선 그리기를 위해 DashedLinePainter CustomPainter 클래스를 구현해줘
- [x] 7.7 DashedLinePainter는 색상, 점선 폭(dashWidth), 점선 간격(dashSpace)을 설정할 수 있어야해

# 8. DashedLinePainter
- [x] 8.1 가장 아래 PlacedRectangle 라인에 파란 점선을 그려주고, 실제로 쓰인 height mm를 파란 점선아래 표시해줘

# 9. TextScanner
- [ ] 9.1 InputView 우하단에 FloatingActionButton 스타일의 원형 아이콘 배치
  - 배경: 파란색 원형
  - 아이콘: 흰색 카메라 아이콘 (Icons.camera_alt)
  - 크기: 56x56 픽셀
- [ ] 9.2 해당 아이콘을 누르면 사진을 찍게 한뒤, 해당 사진의 텍스트를 인식해서 RectangleInputList 에 입력해줘.   
  - 카메라 권한이 없으면 권한 요청 다이얼로그 표시해줘
  - 카메라 권한 거부시, '권한을 허용해야 텍스트로 입력받기가 가능해요' 라고 알려줘
  - 후면 카메라로 선택해줘
  - 이미지는 저장할 필요는 없어
- [ ] 9.3 텍스트는 다음 형식들을 인식해야해. 
  - 패턴: 연속된 3개의 정수 (width, height, count 순서)
  - 구분자: 공백, x, X, *, ×, 쉼표 등 모든 비숫자 문자 허용
  - 예시: "100 x 200 x 3", "100*200*3", "100,200,3", "100mm×200mm×3개"
  - 다른 텍스트가 섞여있어도 패턴만 추출해서 인식
- [ ] 9.4 인식된 모든 패턴을 각각 RectangleInput으로 변환 (줄 구분 없이 모든 유효한 패턴 추출)
- [ ] 9.5 만약 이미 입력되어있는 RectangleInput 들이 있다면 삭제하고 넣어줘.
- [ ] 9.6 유효한 패턴이 하나도 인식되지 않으면 원래 화면으로 복귀하고 '텍스트 인식에 실패했습니다' 메시지 띄워줘
- [ ] 9.7 OCR은 Google ML Kit의 Text Recognition API 사용
- [ ] 9.8 인식중에는 '텍스트 인식 중...' 프로그레스 바 표시해줘
