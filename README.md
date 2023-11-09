# Logo Yazılım & Fırat Üniversitesi LOG-in Bitirme Projesi
Bu proje bir React uygulamasının DevOps kültürü ile hayata geçirme sürecini kapsamaktadır.


# İçindekiler

1. [Proje Hakkında](#proje-hakkında)
2. [React.js uygulamasını oluşturma](#reactjs-uygulamasını-oluşturma)
3. [Docker ile İmaj Oluşturma](#docker-ile-i̇maj-oluşturma)

</br>


# Proje Hakkında
Bitirme projesi dökümanında bulunan yönergeleri takip ederek başlangıç aşamasında React uygulaması oluşturma aracı [Create React App](https://github.com/facebook/create-react-app) kullanarak projeyi oluşturdum.
Oluşturduğum bu projeyi dockerize etmek üzere bir imaj oluşturmak için `Dockerfile` dosyasını hazırladım ayrıca oluşacak konteyner içerisinde olmaması gereken dosyaları hariç tutmak için `.dockerignore` dosyasını ekledim ve bu şekilde imajı olabilecek en minimal boyuta indirgemeye çalıştım. Gitlab CI/CD aracını kullanarak bir boruhattı tasarladım ve Terraform altyapı sağlayıcısı eşliğinde AWS hizmetleri üzerinde ve ayrıca Kubernetes ortamında uygulamayı hayata geçirdim.
<br/>
#### Kullanılan Teknolojiler : 
<span>
<img src="https://i.ibb.co/ThH5V79/logos.png" width=800 heigh=600   style="align:center" />
</span>

<br/>
<br/>
<br/>
<br/>
<br/>

# React.js uygulamasını oluşturma
Döküman içeriğinde bulunan [Create React App](https://github.com/facebook/create-react-app) aracının dökümanını baz alarak ilerledim. Öncelikle ilgili depo içeriğini GitHub üzerinden yerel ortamıma git aracılığı ile şu komutu koşturarak çektim ;
``` 
git clone https://github.com/facebook/create-react-app.git
 ```

Daha sonra yerel ortamıma çektiğim içeriği barındıran dizine geçiş yaparak terminal içerisinde "react-app" isimli projeyi oluşturmak için şu komutu koşturdum ;
``` 
npx create-react-app "react-app"
``` 

Ekranıma oluşturulma sürecindeki izler yansıdı ;

```
PS C:\Users\osman\OneDrive\Masaüstü\create-react-app> npx create-react-app "react-app"

Creating a new React app in C:\Users\osman\OneDrive\Masaüstü\create-react-app\react-app.

Installing packages. This might take a couple of minutes.
Installing react, react-dom, and react-scripts with cra-template...
....
..
.
Happy hacking!
```

Kontrol ettiğimde dizinde "react-app" isimli bir klasör oluştu ve içerisinde React.js projemin uygulama dosyalarını ve bağımlılıklarını içeriyordu.
Daha sonra uygulamayı ayağa kaldırıp bir problem olup olmadığını kontrol etmek istedim ve bunun için React.js "react-app" uygulamasının dizinine geçiş yaparak
```
 npm start
```
Komutunu koşturdum uygulama sorunsuz bir şekilde ayağa kalktı terminal ve tarayıcımın çıktıları şu şekilde oldu ;
<img src="./images/reactjs-install-run.png" width="800"  />

<br/>
<br/>
<br/>
<br/>


# Docker ile İmaj Oluşturma
- **Docker ortam sağlayıcısı** olarak süreci `Docker Desktop` uygulaması ile yürüttüm  
  - Docker Desktop , Windows ve Mac'te kapsayıcıları oluşturmaya ve çalıştırmaya başlamanızı, docker uygulamarını hızla derlemenizi, test etmenizi ve dağıtmanızı sağlayan bir yazılım platformudur.
    
- **Docker imajı nedir ?**
  - Uygulamanızın çalıştırılabilir bir sürümünün ve uygulamanın çalıştırılması için gereken tüm bağımlılıkların bir örneğini içeren bir şablondur.İmajlar, "Dockerfile" adı verilen özel bir betik kullanılarak oluşturulur ve imaj deposunda paylaşılabilirler. 
- **Docker görüntüsü nedir ?,**
  - Bir Docker imajının çalışan bir örneğini ifade eder. Yani Docker imajı bir şablondur ve Docker görüntüsü bu şablonun bir örneğidir. 


Yönergeler imajın boyutunu en düşük olacak şekilde hazırlamamızı istiyor bu nedenle oluşturduğum `Dockerfile` dosyasını **"Bir aşamadan miras alma"** yöntemi ile oluşturdum.

Temel imaj olarak ilk aşama için `node` imajlarından en düşük boyuta sahip olan `node-slim` kullandım. İkinci aşama için çok hafif olan `alpine` altyapısı ve yüksek performansı ile bilinen `nginx` web sunucusunun `nginx:alpine` imajını kullandım.

- Docker çok aşamalı yapısı (Bir aşamadan miras alma) :
  - Docker çok aşamalı yapısı, belirli görevleri gerçekleştirmek için bir görüntü ile başlar ve `AS stagename` komutu ile bu görüntüyü etiketleyerek aşama tamamlandıktan sonra `--from=stagename` komutu ile başlatılan yeni bir görüntü içerisine yalnızca bu aşama için gerekli dosyaları ve bağımlılıkları içerir bu sayede daha küçük ve daha optimize edilmiş Docker görüntüleri elde edebiliriz.

Oluşturmuş olduğum bu [Docker dosyası](./react-app/Dockerfile) iki aşama içermektedir : `development` adı verilen ilk aşama, bağımlılıkları yükler ve uygulamayı oluşturur; `production` adı verilen ikinci aşama ise uygulamayı çalıştırır.

- Docker imajını oluşturmak ve görüntülemek için komut kümesi ;
  - ```
    > docker build -t react-app:1.0 .
    > docker images
    ```
  - <img src="./images/docker-build-list.png" width="800"  />

Docker imajını oluşturduktan sonra imajı test etmek üzere şu aşamaları yürüttüm.
1. **İmajı çalıştırma**
  - ```
     docker run -d -p 3000:80 react-app:1.0 
    ```
    - Bu komut içerisindeki "-p" parametresi "port" bilgisini ifade eder ve "3000" portuna gelen isteklerin "80" portuna yönlendirilmesini sağlamak amacı ile bu şekilde tanımlanmaktadır. İmaj içerisinde "80" portunu açmış olmam nedeni ile bu porta istekleri yönlendirmekteyim.
    - "-d" (detach) parametresi , Docker konteynerini arka planda çalıştırmak için kullanılır.

- Çalışma zamanında konteyneri izlemek için (-d) parametresi olmadan şu komut ile imajı çalıştırıyorum ;
  - ```
     docker run -p 3000:80 react-app:1.0 
    ```   
  - nginx web sunucusunun izleri terminal ekranıma yansımaya başladı.
Tarayıcı aracılığı ile hizmete erişmek için "127.0.0.1:3000" adresine erişmeye çalıştım ve izler içerisinde "GET" isteği oluştu paralelinde tarayıcıma React.js uygulamamın arayüzü yansıdı.

```
PS C:\Users\osman\OneDrive\Masaüstü\PATİKA\hafta 6> docker run -p 3000:80 react-app:1.0 
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
...
..
2023/11/04 18:33:25 [notice] 1#1: nginx/1.25.3
2023/11/04 18:33:25 [notice] 1#1: built by gcc 12.2.1 20220924 (Alpine 12.2.1_git20220924-r10)
2023/11/04 18:33:25 [notice] 1#1: OS: Linux 5.10.16.3-microsoft-standard-WSL2
...
..
172.17.0.1 - - [04/Nov/2023:18:33:30 +0000] "GET / HTTP/1.1" 200 644 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36" "-"
...
..
.
```
Bu şekilde imajımı kontrol etmiş ve konteyner yapısının çalıştığını test etmiş oldum.

2. **Çalışan konteynerları inceleme**
   - Docker içerisinde bulunan tüm konteynerları listelemek için şu komut kullanılır ;
     - `docker ps --all`
   - Ben sadece çalıştırmış olduğum "react-app:1.0" isimli ve versiyonlu konteynerı görmek istediğim için şu komutu koşturuyorum ;
     - `docker ps --filter "ancestor=react-app:1.0"`
     - Çıktı ;
   ```
     CONTAINER ID   IMAGE           COMMAND                  CREATED          STATUS          PORTS                  NAMES
     36fbed07ea40   react-app:1.0   "/docker-entrypoint.…"   48 seconds ago   Up 47 seconds   0.0.0.0:3000->80/tcp   quizzical_shtern
   ```
       
3. **Konteyner detaylarını görüntüleme ve içine girme**
  - Çalışan "36fbed07ea40" ıd bilgisine sahip konteynerın detaylarını görüntülemek için ;
    - `docker inspect 36fbed07ea40` bu komut bize konteynerın bütün detaylarını vermektedir.
```
[
    {
        "Id": "36fbed07ea407b31477f71c6f28fa8a2c1f20e4e481a2492504d36383a531c5c",
        "Created": "2023-11-09T19:08:37.0827641Z",
        "Path": "/docker-entrypoint.sh",
        "Args": [
            "nginx",
            "-g",
            "daemon off;"
        ],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
       ...
       .
        "Ports": {
                "80/tcp": [
                    {
                        "HostIp": "0.0.0.0",
                        "HostPort": "3000"
                    }
                ]
            },
      ...
      .
```
- "36fbed07ea40" ID bilgisine sahip Konteyner içerisine girmek ve bir kabuk(shell) çalıştırmak için şu komutu çalıştırdım.
  - `docker exec -it 36fbed07ea40 /bin/sh`
    - -it ( interaktif mod ile bir bağlantı kurmak istediğimi belirten parametre)
    - Çıktı :
 ```
/ # ls
app                   dev                   docker-entrypoint.sh  home                  media                 opt                   root                  sbin                  sys                   usr
bin                   docker-entrypoint.d   etc                   lib                   mnt                   proc                  run                   srv                   tmp                   var
/ # cd var
/var # ls
cache  empty  lib    local  lock   log    mail   opt    run    spool  tmp
/var # cd log
/var/log # ls
nginx      
/var/log # cd nginx
/var/log/nginx # ls
access.log  error.log
/var/log/nginx # nginx -v
nginx version: nginx/1.25.3
 ```





