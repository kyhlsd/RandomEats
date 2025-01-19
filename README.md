# RandomEats

## 📌 프로젝트 소개
<h2><strong>내 주변 식당을 랜덤 추천해주고, 주위 인기 식당을 보여주는 앱</strong></h2><br/>
<ul>
  <li>API의 연쇄적인 사용을 Combine + Alamofire 활용해 관리</li>
  <li>데이터 흐름에 따라 indicatorView, 사진 표기, 지도 확대/축소 등 View가 따라오도록 중점</li>
  <li>Tuist + 클린 아키텍처 및 시도해보지 않았던 기술 시도해보려는 것에 의의</li>
</ul>
<br/>

> 프로젝트 기간: 2024/11/28 ~ 2025/01/19

> 개인 프로젝트

## 📌 개발도구 및 기술스택

#### 개발환경
- Swift 5.10
- Xcode 15.4
- iOS 17.0
#### 기술스택
- iOS: UIKit
- Software Architecture: 클린 아키텍처 + MVVM
- Tuist, Combine, CombineSwift, Alamofire, RESTful API, Kingfisher



## 📌 기능
<table align="center">
  <tr>
    <th><code>내 주변 식당 랜덤 추천</code></th>
    <th><code>위치 검색</code></th>
    <th><code>내 주변 인기 식당 표기</code></th>
    <th><code>길찾기</code></th>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/c6c80af0-cfd8-4406-bb49-d5624b3ec96c" alt="내 주변 식당 랜덤 추천"></td>
    <td><img src="https://github.com/user-attachments/assets/32bdc12b-a86a-4577-94db-71b65eff7ac1" alt="위치 검색"></td>
    <td><img src="https://github.com/user-attachments/assets/18d903db-2d16-4920-a3dd-46e3f7b59984" alt="내 주변 인기 식당 표기"></td>
    <td><img src="https://github.com/user-attachments/assets/13e279e6-c22c-4cec-925a-f2b966204f72" alt="길찾기"></td>
  </tr>
</table>
<br/>

#### 내 주변 식당 랜덤 추천
- 내 위치, 최대 거리 설정 가능
- Nearby Search API -> Place Detail API 연쇄적으로 사용해 식당 정보 불러오기
- 조건이 변경되었을 시 다시 정보를 가져오고, 조건이 같다면 해당 정보 내에서 다시 랜덤 추천
- Combine + Alamofire 사용해 비동기 처리, 정보를 불러오는 동안 indicatorView 표기

#### 위치 검색
- 위치를 검색해 내 위치를 해당 위치로 사용 가능
- 검색어 입력을 Combine으로 받아 Google Map AutoComplete API를 사용해 장소 검색
- 연쇄적으로 Place Detail API 사용해 해당 장소 주소를 가져와 지도 표기

#### 내 주변 인기 식당 표기
- 내 위치와 최대 거리 설정 가능, 랜덤 추천 뷰와 데이터 연결
- 평점, 리뷰 수를 사용해 인기 식당 5곳을 선정해 표기
- 가장 먼 인기 식당과 현재 위치의 거리를 고려해 지도 확대/축소

#### 길찾기
- 설정된 위치와 식당 사이의 도보 길찾기 기능 제공
- 거리를 고려해 지도 확대/축소


## 📌 회고

#### Keep
- 해보지 못했던 기술 스택을 연습했다는 점에서 의미가 있었다.
- 내가 원하는 정보를 정확히 제공해주는 API가 없었지만 연쇄적인 API 사용을 통해 원하는 정보를 추출해냈다.
#### Problem
- 개인으로 프로젝트를 진행하며 체계적, 계획적이지 못한 부분이 있었다.
- API를 연쇄적으로 호출해야 하다보니 호출 횟수 문제가 있다.
- test 코드를 작성하지 못해 모듈화의 장점을 적극적으로 경험해보지 못했다.
#### Try
- test 코드를 작성해 활용해보고 싶다.
- 적절한 API가 없다면 API + 웹 크롤링 같은 방식도 시도해보고 싶다.
