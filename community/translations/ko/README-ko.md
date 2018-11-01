 This is a community provided translation based off of the main README.md as of Git commit <git sha1>. 
This translation was created by <Park Kyung Min> <pkungm2@gmail.com>
# Chainpoint Node
 [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
 ## 자주 묻는 질문
 도움이 필요하세요? [FAQ](https://github.com/chainpoint/chainpoint-node/wiki/Frequently-Asked-Questions)를 찾고 계신가요 ?
## 요약
Chainpoint Node 는 hash를 수락한 누구나 서버를 실행할 수 있고, 증명을 만들고 검증하며, Chainpoint 네트워크에 참여할 수 있습니다.
Node들은 Chainpoint Core와 통신하고, Chainpoint Network에 서비스를 제공하여 TNT를 획들 할 수 있는 자격을 얻습니다.
 TNT를 획득 할 자격을 얻으려면 다음과 같은 조건을 충족해야 합니다.
* Ehereum 고유 조소로 등록.
* 해당 주소에서 최소 5,000 TNT를 유지.
* 공용 네트워크 서비스를 제공.
* Chainpoint Core에서 감사 및 자체 검사를 통과.
 __* 이러한 모든 요구 사항을 일관되게 충족시키지 못하는 Chainpoint Node들은 주기적인 보상을 통해 TNT를 획득할 자격이 없습니다..*__ 
 ### Node는 무엇을 하나요?
 Chainpoint Nodes는 들어오는 hash를 Merkle tree로 5초마다 집계합니다. Markle root는 공용 블록체인에 앵커링하기 위해서 Chainpoint Core에 제출됩니다.
 Node를 통해 클라이언트는 이전에 제출된 hash에 대한 증명을 검색할 수 있습니다.
 Node는 일정 공유 미러를 유지 관리합니다. 이렇게 하면 *모든* 노드가 *모든* 증명을 확인할 수 있습니다.
Node는 공용 HTTP API를 노출합니다.  여기에 몇가지 추가 문서와, `curl` 혹은 다른 위키에서 찾을 수 있는 클라이언트의 노드 공용 HTTP API 사용 예시들이 있습니다.
 [Node HTTP API](https://github.com/chainpoint/chainpoint-node/wiki/Node-HTTP-API)
 ## 기술 정보
 ### 어떻게 작동하나요?
 Chainpoint Node는 `docker-compose` 어플리케이션과 같이 작동합니다. `docker-compose`는 통합된 응용프로그램 제품군과 같이 작동하는 여러 Docker 컨테이너들의 도구입니다.
Docker 와 `docker-compose`는 Docker가 작동되는 모든 곳에서 바이너리 이미지를 배포 할 수 있습니다.
이렇게 하면 플랫폼에 관계없이 모든 사람이 동일한 코드를 실행하게 됩니다.
Docker를 사용하면 Chainpoint Node 소프트웨어를 쉽게 배포, 업그레이드 할 수 있습니다.
 ### 소프트웨어 구성 요소
 시작이 되면 , `docker-compose`는 일부 시스템 구성 요소를 Docker 가상 머신에 설치하고 실행합니다.
* Chainpoint Node(Node.js API서버 +RocksDB)
* NTP Time server (NTP가 이미 실행되고 있지 않은 경우에만 해당)
이러한 어플리케이션들은 그룹으로 시작되므로 실행중인 다른 소프트웨어 시스템을 방해해서는 안됩니다.
해당작업 전용서버에서 노드를 실행하는 것을 추천 드립니다.
 실행할 각 노드 인스턴스를 다음과 같이 구성해야 합니다.
 * 전용 이더리움 주소
* 공용 IP 주소 (ports `22` and `80` open)
* 최소 TNT 잔액 
 ### 시스템 요구 사항
Docker와 Docker Compose 도구를 지원하고 최소 하드웨어 요구 사항을 충족하는 시스템에서 소프트웨어를 실행되어야 합니다.
 #### 하드웨어
 노드를 실행하기 위한 최적의 하드웨어 요구 사항은 상대적으로 적습니다.
 프로:
 - `>= 4GB RAM`
- `>= 2 CPU Core`
- `>= 2GB swapfile`
- `128GB+ SSD`
- `Public IPv4 address`
 권장 사항:
 - `>= 2GB RAM`
- `>= 2 CPU Core`
- `>= 2GB swapfile`
- `64GB+ SSD`
- `Public IPv4 address`
 최소 사항:
 - `>= 1GB RAM`
- `>= 1 CPU Core`
- `>= 2GB swapfile`
- `25GB+ SSD`
- `Public IPv4 address`
1GB 미만의 RAM을 가진 서버에서 노드를 실행하면 [문제가 발생할 수 있습니다](https://github.com/chainpoint/chainpoint-node/wiki/Frequently-Asked-Questions#operating-and-monitoring-a-node).
 노드는 RAM과 CPU에 비해 비교적 적은 요구사항을 가지고 있습니다. 높은 볼륨의 해시를 지속적으로 수신하는 노드는 SSD에 임시 “증명 상태” 데이터를 기록합니다(약 350MB/해시). 최소 25GB의 SSD 저장공간을 확보하는 것이 좋습니다. 이 임시 데이터는 시간이 지나면 자동으로 제거됩니다.
데이터 저장을 위해 내부적으로 사용되는 RocksDB는 SSD 디스크에 최적화 되어 있습니다. 가능하면 기존의 하드 디스크 대신 SSD 디스크를 사용하는 것이 좋습니다.
대용량의 해시가 서버로 전송되는 경우 RAM 및 SSD 디스크 저장소를 추가하여 시스템을 확장하는 것이 좋습니다.
단일 물리적 호스트에서 노드 소프트웨어의 여러 인스턴스를 실행하는 것은 지원되지 않습니다.
 #### 운영체제
이 소프트웨어는 테스트를 거쳤으며 다음 운영 체제에서 지원됩니다:
* `Ubuntu 16.04 LTS`
* `macOS Version 10.12.6+`
 Docker 및 Docker Compose를 지원하는 다른 운영 체제에서도 실행될 수 있지만, 현재 운영체제에 대한 지원을 제공하지 않습니다.
 #### Docker & Docker Compose
 노드는 다음 소프트웨어 버전에서 개발되고 테스트 되었습니다.
* `Docker version 18.05.0-ce, build f150324`
* `docker-compose version 1.21.2, build a133471`
 ## 설치
 이 소프트웨어는 지원되는 운영체제에서 설치 및 실행이 간편하도록 설계되었습니다. 시작하려면 아래 지침을 따르십시오.
다음 지침은 `Ubuntu 16.04 LTS` 운영 체제를 실행하는 모든 공용 호스트에서 실행되어야 합니다.
 ### 전제 조건
 시작하기 이전에 다음 조건이 필요합니다:
 *개인 키를 가지고 있는 Ethereum 주소. Exchange에서 제공하는 계정은 일반적으로 지원되지 않습니다.
 예를 들어 MyEtherWallet을 사용하여 Ether 또는 TNT를 보내기 위해서는 계정을 잠금 해제 할 수 있어야 합니다.
* An Ethereum address that you have the private keys for. Exchange provided accounts are generally not supported. You should be able to unlock your account to send Ether or TNT using MyEtherWallet for example.
*노드를 실행하려면 최소 5,000 TNT를 가져야 하며, 노드를 식별하는 데 사용할 Ethereum 주소에 TNT를 할당해야 합니다. Etherscan.io를 사용해 TNT 잔액(Grains 단위로, TNT 잔액에 대해 (10^8)으로 나눔)을 확인 할 수 있습니다.[스마트 계약을 위한 우리의 계약서 판독 도구 ERC20](https://etherscan.io/address/0x08f5a9235b08173b7569f83645d2c7fb55e8ccd8#readContract)(`balanceOf`필드에 주소를 입력하고 `Query`를 클릭).
 노드를 조직하는데 문제가 발생하면 Wiki의 [자주 묻는 질문](https://github.com/chainpoint/chainpoint-node/wiki/Frequently-Asked-Questions) 페이지에서 도움을 요청할 수 있습니다.
 ### 서버 시작
 첫 단계는 서버를 시작하고 해당 서버에서 계정에 대한 SSH 액세스를 얻는 것입니다.
이것은 이 문서의 범위에서 벗어난 것입니다.
다음이 필요합니다:
 * `root` 액세스, 또는 `sudo` 사용자 권한.
* Ubuntu 16.04 LTS OS
 항상 호스트 공급자가 제공하는 가장 간단한 Ubuntu 16.04 이미지를 선택해야 합니다. "Desktop" 버전 또는 `ufw` 을 기본 방화벽으로 설정된 버전은 Docker 및 시스템 방화벽에 호환성 문제가 있으므로 사용이 권장되지 않습니다.   
SSH를 통해 서버에 로그인하고, 다음 단계에 Docker 와 `docker-compose`를 설치 하십시오.
 ### Docker 및 Docker Compose 설치
 이 프로세스를 쉽게 하기 위해 `Ubuntu 16.04 LTS`에서 작동하도록 설계된 작은 스크립트를 작성했습니다.
이는 한 줄 명령으로 모든 런타임 종속성을 설치합니다.
 ```sh
curl -sSL https://chainpoint-node.storage.googleapis.com/setup.sh | bash
```
이 명령은 운영체제에서 권한이 있는 사용자로서 쉘 스크립트를 실행하기 때문에 실행하기 전에 [신중하게 검사하는 것](https://github.com/chainpoint/chainpoint-node/blob/master/scripts/setup.sh)이 좋습니다.
명령을 터미널에 복사,붙여 넣기 하고 root 사용자로서 로그인 하거나, sudo 권한을 가진 다른 사용자로서 로그인하면 다음과 같은 작업이 수행됩니다:
 * Docker 설치
* Docker Compose 설치
* 재부팅 할 수 있는 2GB 스왑 파일 구성
* 스왑 성능과 관련된 시스템 구성 조정
* `sudo`를 사용하지 않고 로컬 사용자가 Docker 명령을 실행할 수 있는 기능을 부여
* 이 저장소를 홈 폴더에 다운로드
* 편집을 준비하기 위해 `.env` 기본 환경 파일 생성
 **중요사항**: 터미널 SSH 세션을 닫은 다음 스크립트를 실행 한 이후 다시 로그인하여 스크립트 변경 사항이 완전히 적용되었는지 확인해야 합니다. 서버를 재부팅 할 필요는 없습니다.
 #### 수동 설치
수동으로 설치하기 원한다면 Ubuntu 서버에 Docker를 설치하는 데 [유용한 지침](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04) 이 있습니다.
 다른 운영체제에서 [Docker를 설치하는 공식 문서](https://docs.docker.com/engine/installation/).
 일부 운영체제의 경우 별도로 `docker-compose`를 설치해야 합니다.
 ### NTP와 시스템 시간을 동기화 하십시오.
 Linux 서버는 NTP(Network Time Protocol)이라고하는 시스템 서비스를 사용하여 매우 정확한 원본 시간과 동기화합니다. 서버를 설치하는 것이 매우 쉽기 때문에 국제 표준 시간의 밀리 초 또는 마이크로 초 안에 머무르게 됩니다. 
 Chainpoint Nodes의 경우 구글에서 제공하는 공용 NTP 시간 서버를 사용하는 것이 좋습니다. 그렇게 하면 서버가 최대한 Chainpoint Core 서버 시간에 가까워집니다. 노드가 허용 오차 범위 내에 있는지(현재 최대 5초) 노드가 지속적으로 확인될 것입니다. 시간이 지남에 따라 보상을 받을 수 있도록 NTP를 설정하십시오. 
* [Google Public NTP](https://developers.google.com/time/)
*[Ubuntu 16.04에서 NTP 풀 프로젝트에 사용할 NTP를 구성하는 방법](https://www.digitalocean.com/community/tutorials/how-to-configure-ntp-for-use-in-the-ntp-pool-project-on-ubuntu-16-04)
 시스템이 자신의 NTP 데몬을(많은 사람들이 기본적으로 하는) 실행하고 있지 않은 경우, 권한을 가진 Docker 컨테이너는 노드의 시작 및 지속적인 동기화를 시도합니다.
 ### 노드 구성
 구성은 단일 구성 파일을 편집하고 두개의 변수를 제공하는 것처럼 간단합니다. `.env.sample`.라 불리는 저장소에서 샘플 구성 파일을 제공합니다.
설치 스크립트를 사용하면 해당 파일이 `~/chainpoint-node/.env`로 복사되어 편집할 준비가 완료됩니다.
수동으로 모든 것을 설치했다면 다음이 요구됩니다:
 ```sh
cd ~/chainpoint-node
cp .env.sample .env
 # 선호하는 편집기를 사용하십시오:
vi .env
```
 편집해야 할 수도 있는 값은 두 가지입니다.(명확성을 위해 주석이 제거되었습니다):
 ```sh
NODE_TNT_ADDRESS=
CHAINPOINT_NODE_PUBLIC_URI=
```
 `NODE_TNT_ADDRESS` : Ethereum 주소를 TNT 잔액이 포함된 것으로 설정해야 합니다. 이것은 `0x` 와 40개의 16진수 문자(`0-9, a-f, A-F`)로 시작합니다. 이것은 노드의 고유 식별자입니다.
 `CHAINPOINT_NODE_PUBLIC_URI` : 노드를 공개적으로 검색하고 다른 사람들이 사용할 수 있는 UTL이여야 합니다. 이것은 마치 `http://10.1.1.20`과 같이 보일 것입니다. 노드가 `http`를 넘어 `80` 포트에서 실행될 것입니다. 이 주소가 제공되면, 이 주소는 정상적인 노드에 대한 규칙을 준수하는지 확인하기 위해 Chainpoint Core에 의해 주기적으로 확인됩니다. 이 설정 값을 공백으로 남겨두면, Node가 공개적으로 사용 가능하지 않다고 가정하여 TNT 보상을 받을 자격을 얻을 수 없습니다. 
 일단 실행되면 `http://YOURIP/config` 인터넷상의 다른 호스트에서 방문하여 JSON 응답을 볼 수 있어야 합니다.
 ### 노드 방화벽
 노드의 네트워크 보안은 전적으로 노드 사용자의 책임입니다. 우리는 노드 서버의 보안 설정이나 방화벽을 관리하거나 수정하지 않습니다.
대부분의 호스팅 제공 업체는 기본적으로 들어오는 모든 트래픽(포트 22의 SSH 제외)을 차단합니다. 노드에 클라이언트를 연결할 수 있게 하려면 포트 80(HTTP)를 전세계에 노출시켜야 합니다.
이는 비공개 호스트를 방화벽이나 공용 호스트 뒤에서 실행하든 상관없습니다.
만약 당신의 공급자가 기본 정책으로 블록을 구현하지 않는 경우, `80 (HTTP)` 와 포트 `22 (SSH) `를 제외한 모든 포트에 대한 접근을 차단하도록 노드 서버에서 다른 제공자를 선택하거나 방화벽을 구성하는 것이 좋습니다. 
 당신이 Docker가 방화벽과 상호작용하는 방식을 이해하고 있는 *전문가*가 아닌 이상 노드 서버에서 `ufw`와 같은 로컬 방화벽 소프트웨어를 실행하는 것은 바람직하지 않습니다. `ufw`와 그외 비슷한 툴들은 Docker를 방해하는 것으로 알려져 있습니다.
 ### 노드 실행
 이제 당신의 노드를 시작하십시오!
 `.env` file에서 구성을 완료하고 저장하면 `~/chainpoint-node`디렉토리에 있는지 확인하고 `make`를 실행하십시오.
이것은 사용가능한 Makefile 명령들을 보여줄 것입니다. 더 중요한 것들은 다음과 같습니다:
 * `make up` : 모든 서비스 시작
* `make down` : 모든 서비스 중지
* `make upgrade` : git에서 최신 릴리스로 업그레이드하고 다시 시작
* `make restart` : git을 변경하지 않고 Node 소프트웨어만 재시작
* `make logs` : `docker-compose` 로그파일 표시 및 종료
* `make ps` : 실행중인 프로세스의 상태 표시
 이 시점에서 가장 간단한 단계는 `make up`을 실행하는 것입니다. 
이렇게 하면 적절한 Docker 이미지(업그레이드가 가능하거나 느린 네트워크 상에서는, 처음 몇 분이 소요 될 수 있습니다) 가 자동으로 풀립니다. `docker-compose`가 충돌할 가능성이 적지만 매우 안정적인 경우에도 노드가 계속 실행되도록 합니다.
SSH 세션에서 로그 아웃하면 위에서 설명한대로 노드를 시작해도 노드에 영향을 미치지 않습니다.
 ### 노드 모니터링
 노드이 상태 및 작동을 모니터링하는 두 가지 주요 방법이 있습니다. 인증된 웹 콘솔과 명령을 통해.
 #### 노드 웹 UI
 노드가 실행되면 `http://<YOUR-NODE-IP-ADDRESS>`URL을 브라우저에서 방문할 수 있습니다. 이 UI는 기본적으로 공개되지 않으므로 인증하라는 메시지가 표시됩니다. 노드 UI의 기본 암호는 `.env` 구성 파일에서 설정한  NODE_TNT_ADDRESS`와 같습니다.
 노드 UI는 현재 활동과 관련된 정보와 두번의 시간별 확인 과정에서 측정된 노드 상태에 대한 코어의 통계 및 대기열의 활성 노드 수에 대한 정보를 제공합니다. '활동' 페이지 데이터는 몇 초마다 업데이트되면 '정보' 페이지 노드 상태 정보는 매 시간 업데이트 됩니다. 상태 데이터는 노드에 비공개로 간주되며 암호 학적으로 서명된 데이터 패킷으로 노드에 푸시됩니다. 유사한 정보를 검색할 수 있는 공용 API는 없습니다.
 노드 UI에 대한 고유 암호를 설정하려면, `.env.sample`파일에 제공된 지시 사항이 있습니다.
 #### 명령 행
 `docker` 서비스를 확인하기 위해 터미널 SSH 세션에서 `make ps`를 실행 하십시오.
 `docker-compose` 관리 서비스의 로그파일에 대하여 지속적으로 추적하기 위해서 `make logs`를 실행 하십시오. 
 노드를 시작하면 로그에서 노드가 Chainpoint 코어 clustersd 중 하나에 등록하려고 시도하고 비밀키가 제공됩니다.
그런 다음 노드는 다운로드 프로세스를 수행하고 전체 체인 포인트 일정을 암호로 확인합니다. 모든 블록은 서명이 체크되고 로컬에 저장됩니다. 캘린더가 커짐에 따라 이 프로세스는 처음 실행될 때까지 약간의 시간이 걸릴 수 있습니다. 초기 동기화 후, 모든 증분 변경 사항은 모든 노드로 끌어 내려져 확인되고 저장됩니다.
로그에 표시되는 문제가 있거나 예상대로 작동하지 않는 경우 [버그를 신고](https://github.com/chainpoint/chainpoint-node/issues)하고 가능하면 문제에 대한 많은 정보를 제공하십시오.
 ### CLI를 사용하여 노드에 해시 보내기
 이제 당신은 완전히 가동해야 한다! [Chainpoint 명령행 인터페이스(CLI)](https://github.com/chainpoint/chainpoint-cli)를 이용하여 새 노드를 시험해 볼 수 있습니다.
 일반적으로 CLI는 해시를 보낼 노드를 자동으로 검색합니다. 원하는 경우 노드를 사용하도록 구성 할 수 있습니다.
 `~/.chainpoint/cli.config`에서 노드 주소를 영구적으로 설정하기 위해 변경 할 수 있고, 다음과 같이 사용할 때마다 노드 주소를 무시 할 수 있습니다.
 ```sh
chp submit --server http://127.0.0.1 <hash>
```
 ### 노드 중지
 `make down`로 언제든지 노드를 중지 할 수 있습니다. `make ps`로 모든 것이 중지되었는지 확인할 수 있습니다.
 ### 노드 인증 키 백업/복원
 *tl;dr* : 서버에서의 백업이 이제 자동으로 수행됩니다(`v1.5.3+`).`make print-auth-keys`로 인증키를 보내고 그 백업을 다른 위치에 저장하십시오!!!
 이 명령은 `STDOUT`콘솔로 `HMAC`키를 인쇄하고 다른 호스트의 인증 키를 복원하는 데 도움되는 편리한 한 줄짜리 `echo`명령을 제공합니다.
 다음 정보는 향후 어느 시점에 노드를 백업 / 복원하거나 새로운 호스트 서버에서 실행해야 하는 경우에 유용 할 수 있습니다.
### 인증 키 정보
 노드가 시작되고 Chainpoint Core에 자신을 등록하면 `HMAC` 또는 `Auth` 라고하는 비밀 키가 생성되어 노드와 공유됩니다. 이 키의 공유는 노드를 처음 등록 할 때 한번만 필요합니다. 키는 노드의 로컬 데이터베이스에 저장됩니다. 노드가 시작될 떄마다 이 키를 사용하여 Chainpoint Core를 인증하고 필요에 따라 등록 된 공개 IP주소를 업데이트합니다. 노드 데이터 베이스는 여러 인증 키를 저장할 수 있으며 `.env`파일의 `NODE_TNT_ADDRESS` 환경변수에서 구성한 Ethereum 주소를 기반으로 일치하는 키를 선택 합니다.
 *주의* : 비밀 키를 분실 한 경우:
 * 다른 수단으로 그것을 복구 할 수 없습니다
* Ethereum(TNT) 주소와 관련된 인증 키를 "재설정" 할 방법이 없습니다
* 동일한 Ethereum 주소를 사용하여 다른 노드를 시작할 수 없습니다.
손실을 방지하기 위해 우발적인 삭제가 발생했을 때이를 백업하고 안전한 곳에 저장하는 것이 좋습니다.
#### 백업
 v1.5.3+ 에서는 노드가 코어에 등록되고 시작할 때마다 노드가 자동으로 백업을 수행합니다.
이렇게 하면 데이터베이스안에 노드의 하위 디렉토리인 `keys/backups`의 모든 인증키에 대한 백업파일이 생성됩니다 백업파일 이름은 ETH주소와 현재 시간을 합친 형식으로 구성 됩니다: `<ETH_ADDRESS>-<TIMESTAMP>.key`.
파일 내용은 해당 주소와 연관된 HMAC Auth 키인 텍스트 한 줄입니다.
 #### 복원
 인증 키의 백업 복사본 복원은 쉽습니다. 노드가 시작될 때마다 `~/chainpoint-node/keys`디렉토리의 내용을 봅니다. 이름에 다음 두 가지 패턴 중 하나가 있는 파일을 찾으면 파일에서 auth 키를 읽고 이를 자동으로 노드로 가져옵니다.
 * `<ETH_ADDRESS>.key`
* `<ETH_ADDRESS>-<TIMESTAMP>.key`
  `.key` 파일의 내용은 단순히 HMAC 인증키의 주소에 대한 한 행입니다.
 `.key` 파일은 위의 백업 절차를 통해 만들 수 있으며 수동으로 만들 수 있습니다.
수동으로 작성하는 경우, 파일 이름에 타임 스탬프를 포함할 필요가 없습니다.
 __수동으로 생성한 파일 복원__
 백업 파일을 만듭니다.(예:암호 관리자로 `make print-auth-keys`의 출력을 복사). 새로운 인증 키를 가져 오기 위해 `make restart`로 노드를 재시작 하십시오. `make print-auth-keys` 명령은 다음과 같이 키를 복원하는데 사용 할 수 있는 echo 문도 인쇄합니다:
 ```sh
# 키의 백업 파일을 수동으로 생성하는 예
# 이것을 `chainpoint-node` 디렉토리에서 실행하십시오/ 
echo -n "my-secret-auth-hmac-key" > keys/0xMYETHADDRESS.key
```
 __이전에 백업된 파일 복원__
 `~/chainpoint-node/keys/backups` 디렉토리에 백업 파일이 있습니다.
 파일 이름이 `.env` 파일에 구성된 `NODE_TNT_ADDRESS`와 일치하는 백업 파일을 `~/chainpoint-node/keys/backups` 디렉토리에서 `~/chainpoint-node/keys` 디렉토리로 복사합니다.
`make restart` 로 노드를 재시작 한 이후 `.key` 파일을 `keys/` 디렉토리에 배치.
 __복원 확인__
 노드가 재시작 되고 `.key` 파일을 `~/chainpoint-node/keys` 디렉토리 안에서 발견할 경우 로컬 데이터베이스에 해당 파일의 인증 키를 복원하려고 합니다. 성공하면 `make logs` 출력에 다음과 비슷한 행이 표시됩니다:
 ```sh
INFO : Registration : Auth key saved to local storage : 0x<MYETHADDRESS>-<TIMESTAMP>.key
```
 ## 자주 묻는 질문
 노드 사용자가 제시한 많은 질문에 대한 답변과 유용한 팁은 [FAQ](https://github.com/chainpoint/chainpoint-node/wiki/Frequently-Asked-Questions#operating-and-monitoring-a-node)에서 확인 할 수 있습니다. 
 문제를 제기하기 이전에 문서를 참조하십시오.
## 특허
 [Apache 라이센스, 버전 2.0](https://opensource.org/licenses/Apache-2.0)
 ```text
Copyright (C) 2017-2018 Tierion
 Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
     http://www.apache.org/licenses/LICENSE-2.0
 Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
 ## 감사합니다!
 Chainpoint Network에 적극적으로 참여하고 Chainpoint 노드를 실행 해 주셔서 감사드립니다. 당신의 참여 없이는 할 수 없었습니다!
