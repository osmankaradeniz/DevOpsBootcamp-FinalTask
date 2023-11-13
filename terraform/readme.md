# Terraform altyapı sağlayıcısı eşliğinde AWS hizmetlerine Dağıtım gerçekleştirmesi
Döküman içerisinde bulunan yönergelere göre `terraform` teknolojisi ile AWS hizmetleri üzerinde uygulamamızın dağıtılması istenmektedir.

Dökümanda belirtilen isterler ;
 * Uygulamayı `terraform` altyapı sağlayıcı ile dağıtılmalıdır.  
 * Uygulamanın çalışması için `ECS Fargate hizmeti` kullanılmalıdır.
 * VPC ve güvenlik grubu ayarları tanımlanmalıdır.
 * Uygulama yük dengeleyicisi hizmeti tanımlanmalıdır.


Önceki aşamada açıkladığım işlem hattımın aşamalarında `deploy`,`destroy`  terraform altyapı sağlayıcısı kullanıldığımızı bahsetmiştim.
<div>
<details>
  <summary>Terraform ile ilgili kavramlar tablosu</summary>

  | **Başlık** | **Açıklama** |
  |------------|--------------|
  | Terraform Nedir? | Terraform, altyapıyı kod olarak tanımlamak ve yönetmek için kullanılan açık kaynaklı bir araçtır. Hafif, kullanımı kolay ve çoklu bulut sağlayıcılarda çalışabilir. |
  | HCL Nedir? | HCL, HashiCorp Configuration Language'ın kısaltmasıdır. Terraform konfigürasyon dosyalarını yazmak için kullanılan açık ve insan dostu bir dilidir. |
  | Terraform İşleme Mantığı | Terraform, bir altyapıyı kod olarak tanımlayan HCL dosyalarını okur, değişiklikleri belirler ve belirlenen durumu sağlamak için ilgili kaynakları oluşturur, günceller veya siler. |
  | Terraform Neden Gereklidir? | Terraform, altyapıyı yönetmenin programatik bir yolunu sağlar, bu da tekrarlanabilir, güvenilir ve ölçeklenebilir bir altyapı oluşturmak için önemlidir. Ayrıca, birden çok bulut sağlayıcıyı destekler. |
  | .tfstate Nedir? | `.tfstate` dosyası, Terraform tarafından yönetilen altyapının durumunu saklayan bir dosyadır. Bu dosya, oluşturulan kaynakların durumunu, değişiklikleri ve sahip oldukları bağımlılıkları içerir. |

</details>

<details>
  <summary>AWS ile ilgili kavramlar tablosu</summary>

  | **Başlık** | **Açıklama** |
  |------------|--------------|
  | AWS Fargate | AWS Fargate, kullanıcıların konteyner çalıştırmak için sunucu yönetimine ihtiyaç duymadan Amazon ECS veya Amazon EKS üzerinde konteynerlerini çalıştırmalarına olanak tanıyan bir hizmettir. |
  | VPC (Virtual Private Cloud) | VPC, Amazon Web Services (AWS) bulutunda izole bir ağ sağlayan ve kullanıcının özelleştirilebilir IP adres aralıkları, alt ağlar, yönlendirme tabloları ve ağ geçitleri belirleyebildiği bir servistir. |
  | Security Group | AWS Security Group, EC2 örnek ve RDS veritabanları gibi kaynakların erişimini kontrol etmek için kullanılan sanal güvenlik duvarı kurallarını tanımlayan bir AWS öğesidir. |
  | Task Definition | AWS ECS (Elastic Container Service) için Task Definition, çalıştırılacak konteynerleri ve bu konteynerlerin yapılandırmasını tanımlayan bir nesnedir. |
  | Service | AWS ECS hizmeti, belirli bir görev tanımını kullanarak çalıştırılacak ve yönetilecek bir grup konteyneri temsil eder. |
  | Internet Gateway | Internet Gateway, VPC'ye bağlı bir ağ geçididir ve özel bir VPC içindeki kaynakların internetle iletişim kurmasına olanak tanır. |
  | Subnet | Subnet, bir VPC içindeki IP adres aralığından bir alt kümedir. Subnetler, aynı VPC içinde bulunan kaynakları mantıksal olarak gruplamak için kullanılır. |
  | Route Table | Route Table, bir VPC içindeki alt ağlara yönlendirme kararları sağlayan bir AWS öğesidir. |
  | ENI (Elastic Network Interface) | ENI, bir Amazon EC2 örneği veya Lambda fonksiyonu gibi AWS hizmetleri ile ilişkilendirilmiş bir sanal ağ arabirimini temsil eder. |
  | Availability Zone (AZ) | Availability Zone, AWS'nin fiziksel veri merkezlerini temsil eden bölümlerdir. Bir bölge içinde birden çok AZ bulunabilir. |
  | ECR (Elastic Container Registry) | ECR, Docker konteyner görüntülerini depolamak, yönetmek ve dağıtmak için kullanılan tamamen yönetilen bir Docker konteyner görüntü depolama servisidir. |
  | IAM (Identity and Access Management) | IAM, AWS içinde kimlik ve erişim yönetimini sağlayan bir servistir. Kullanıcı, rol ve politika gibi kavramları içerir. |
  | Task Execution Role | AWS ECS görevleri için tanımlanan IAM rolüdür. Görev çalıştırıldığında, bu rolden türetilen güvenlik kimliği kullanılır. |

</details>
</div>


## Terraform Kaynakları
<div>
<details>
<summary><strong>vpc.tf Dosyası Detayları</strong></summary>
  
### AWS Terraform VPC ve Yük Dengeleyici Konfigürasyonu
  AWS üzerinde bir sanal özel bulut (VPC) oluşturmak ve içinde bir yük dengeleyici ağ konfigürasyon yapmak için.

### 1. VPC (`aws_vpc`)
- **Açıklama:** Sanal özel bulutun ana yapı taşı.
- **Amaç:** Kaynakları izole etmek ve ağ altyapısını tanımlamak.
- **Özellikler:**
  - `cidr_block`: VPC'nin IP adres aralığı (10.0.0.0/16).
  - `instance_tenancy`: Default.
  - `enable_dns_hostnames`: DNS host adlarını etkinleştirme.
  - `tags`: VPC'ye etiket ekler (örneğin, "main-vpc").

### 2. Internet Gateway (`aws_internet_gateway`)
- **Açıklama:** VPC ile internet arasında iletişimi sağlayan ağ geçidi.
- **Amaç:** İnternet erişimini mümkün kılmak.
- **Özellikler:**
  - `vpc_id`: Bağlı olduğu VPC'nin kimliği.

### 3. Subnetlar (`aws_subnet`)
- **Açıklama:** VPC içindeki alt ağlar.
- **Amaç:** Kaynakları bölge ve güvenlik ayarlarına göre gruplamak.
- **Özellikler:**
  - `cidr_block`: Subnet'in IP adres aralığı.
  - `vpc_id`: Subnet'in bağlı olduğu VPC'nin kimliği.
  - `availability_zone`: Subnet'in bulunduğu bölge.
  - `map_public_ip_on_launch`: Yeni başlatılan örnekler için genel IP adresleri atanıp atanmayacağını belirler.

### 4. Route Table (`aws_route_table`)
- **Açıklama:** Yönlendirme kurallarını tanımlayan bir tablo.
- **Amaç:** İnternet erişimi için yönlendirme kurallarını belirlemek.
- **Özellikler:**
  - `vpc_id`: Tablonun bağlı olduğu VPC'nin kimliği.
  - `route`: Hedef ve hedefe erişim kuralları.

### 5. Route Table Association (`aws_route_table_association`)

- **Açıklama:** Subnetleri belirli bir yönlendirme tablosuna bağlar.
- **Amaç:** Subnetlerin belirli bir yönlendirme tablosunu kullanmasını sağlamak.
- **Özellikler:**
  - `route_table_id`: Bağlanacak yönlendirme tablosunun kimliği.
  - `subnet_id`: Bağlanacak subnetin kimliği.

### 6. Security Groups (`aws_security_group`)

- **Amaç:** İzin verilen trafiği denetlemek.
  - `alb_sg`: Yük dengeleyici için güvenlik grubu.
  - `service_sg`: Hizmet için güvenlik grubu.

### 7. Load Balancer Target Group (`aws_lb_target_group`)

- **Açıklama:** Yük dengeleyici için hedef grup.
- **Amaç:** Yük dengeleyici tarafından yönlendirilecek hedefleri belirtmek.
- **Özellikler:**
  - `name`: Hedef grubunun adı.
  - `port`: Hedef grubuna yönlendirilen port.
  - `protocol`: Hedef grubu için iletişim protokolü.

### 8. Load Balancer Listener (`aws_lb_listener`)

- **Açıklama:** Yük dengeleyici için dinleyici.
- **Amaç:** Gelen istekleri yönlendirmek.
- **Özellikler:**
  - `load_balancer_arn`: Bağlı olduğu yük dengeleyicisinin kimliği.
  - `port`: Dinleyicinin dinlediği port.
  - `protocol`: Dinleyicinin iletişim protokolü.
  - `default_action`: Varsayılan işlem, genellikle hedef grubuna yönlendirme.

</details>




<details>
<summary><strong>ecs.tf Dosyası Detayları</strong></summary>
  
### ECS Cluster ve Hizmet Konfigürasyonu

AWS üzerinde ECS (Elastic Container Service) kümesi ve bir konteyner hizmeti konfigürasyonu oluşturur.

### 1. ECS Kümesi (aws_ecs_cluster)

- **Amaç:** ECS konteyner örneklerini barındıran bir küme oluşturmak.
- **Özellikler:**
  - `name`: ECS kümesinin adı ("reactjs-app-cluster").

### 2. ECS Görev Tanımı (aws_ecs_task_definition)

- **Amaç:** Çalıştırılacak konteynerlerin özelliklerini belirlemek.
- **Özellikler:**
  - `container_definitions`: Konteyner konfigürasyonunu JSON formatında belirtir.
  - `family`: Görev tanımının adı ("reactjs-app").
  - `requires_compatibilities`: FARGATE uyumluluğunu belirtir.
  - `cpu`, `memory`: Konteyner özellikleri.
  - `network_mode`: Ağ modu ("awsvpc").
  - `task_role_arn`, `execution_role_arn`: Görev ve yürütme rollerinin ARN'leri.

### 3. Uygulama Yük Dengeleyicisi (aws_alb)

- **Amaç:** Uygulama yük dengeleyici oluşturmak.
- **Özellikler:**
  - `name`: Yük dengeleyicisinin adı ("reactjs-app-alb").
  - `load_balancer_type`: Yük dengeleyici tipi ("application").
  - `subnets`: Kullanılacak alt ağlar.
  - `security_groups`: Güvenlik grubu.

### 4. ECS Hizmeti (aws_ecs_service)

- **Amaç:** ECS kümesinde çalışacak bir konteyner hizmeti oluşturmak.
- **Özellikler:**
  - `name`: Hizmetin adı ("reactjs-app-service").
  - `cluster`: Bağlı olduğu ECS kümesinin ARN'si.
  - `launch_type`: FARGATE kullanımını belirtir.
  - `enable_execute_command`: Konteynerlere SSH gibi komutları etkinleştirme.
  - `deployment_maximum_percent`, `deployment_minimum_healthy_percent`: Dağıtım özellikleri.
  - `desired_count`: Çalıştırılacak konteyner sayısı.
  - `task_definition`: Kullanılacak görev tanımının ARN'si.
  - `load_balancer`: Yük dengeleyici konfigürasyonu.
  - `network_configuration`: Ağ konfigürasyonu (genel IP atanması, güvenlik grupları, alt ağlar).

</details>


<details>
<summary><strong>variables.tf Dosyası Detayları</strong></summary>
  
### AWS Değişkenleri

AWS konfigürasyonu için gerekli değişkenleri tanımlar.

### 1. AWS Bölgesi Değişkeni (AWS_REGION)

- **Amaç:** Terraform tarafından kullanılacak AWS bölgesini belirtmek.
- **Özellikler:**
  - `type`: Değişken tipi (string).
  - `default`: Varsayılan değer ("eu-central-1").

### 2. AWS Erişim Anahtarı Değişkeni (AWS_ACCESS_KEY)

- **Amaç:** AWS hesabına erişim sağlamak için kullanılan erişim anahtarını belirtmek.
- **Özellikler:**
  - `description`: Değişkenin açıklaması.
  - `type`: Değişken tipi (string).
  - `default`: Varsayılan değer ("###").

### 3. AWS Gizli Anahtar Değişkeni (AWS_SECRET_KEY)

- **Amaç:** AWS hesabına erişim sağlamak için kullanılan gizli anahtarını belirtmek.
- **Özellikler:**
  - `description`: Değişkenin açıklaması.
  - `type`: Değişken tipi (string).
  - `default`: Varsayılan değer ("####").

**Bu değişkenler, Terraform uygulamasının AWS kaynaklarını oluştururken kullanılacak temel bilgileri içerir. AWS_REGION değişkeni, hangi AWS bölgesinde kaynakların oluşturulacağını belirler. AWS_ACCESS_KEY ve AWS_SECRET_KEY değişkenleri, AWS hesabına Terraform'un erişmesi için gerekli olan kimlik bilgilerini içerir. Bu değişkenler, güvenlik ve esneklik sağlamak amacıyla dış bir dosyadan veya Terraform'un çalıştığı ortam değişkenlerinden alınabilir.**
 </details>


<details>
<summary><strong>config.tf Dosyası Detayları</strong></summary>
  
### AWS Sağlayıcı Konfigürasyonu

Terraform'un AWS sağlayıcısının konfigürasyonunu belirtir.

### AWS Sağlayıcı (provider)

- **Amaç:** AWS sağlayıcısını belirtmek ve gerekli konfigürasyon bilgilerini sağlamak.
- **Özellikler:**
  - `region`: AWS kaynaklarının hangi bölgede oluşturulacağını belirlemek için `var.AWS_REGION` değişkenini kullanır.
  - `access_key`: AWS hesabına erişim sağlamak için kullanılan erişim anahtarını `var.AWS_ACCESS_KEY` değişkeninden alır.
  - `secret_key`: AWS hesabına erişim sağlamak için kullanılan gizli anahtarını `var.AWS_SECRET_KEY` değişkeninden alır.

**Terraform'un AWS sağlayıcısını etkinleştirir ve AWS kaynaklarını bu sağlayıcı üzerinden yönetmesini sağlar. `region`, `access_key`, ve `secret_key` değerleri, önceki değişkenler dosyasında tanımlanan değişkenlerden alınarak AWS sağlayıcısına iletilir. Bu sayede AWS ile etkileşim kurmak için gerekli olan temel bilgiler sağlanmış olur.**

</details>

<details>
<summary><strong>ecr.tf Dosyası Detayları</strong></summary>
  
### AWS ECR Deposu Konfigürasyonu
AWS Elastic Container Registry (ECR) için bir Docker imaj deposunun konfigürasyonunu belirtir.

### Docker Imaj Deposu (aws_ecr_repository)

- **Amaç:** AWS ECR'de bir Docker imaj deposu oluşturmak.
- **Özellikler:**
  - `name`: Imaj deposunun adı ("reactjs-app-repo").
  - `image_tag_mutability`: Imaj etiketlerinin değiştirilebilirliği ("MUTABLE").
  - `image_scanning_configuration`: Imaj tarama konfigürasyonu.
    - `scan_on_push`: Imaj eklendiğinde tarama yapılıp yapılmayacağını belirtir (true).

**AWS ECR'de bir Docker imaj deposu oluşturur. `name` özelliği, oluşturulan imaj deposunun adını belirtir. `image_tag_mutability` özelliği, imaj etiketlerinin değiştirilebilirliğini belirler; bu durumda "MUTABLE" olarak ayarlanmıştır. `image_scanning_configuration` bloğu, imaj tarama konfigürasyonunu belirtir ve `scan_on_push` özelliği, her imaj eklendiğinde taramanın yapılıp yapılmayacağını belirler; bu durumda `true` olarak ayarlanmıştır. Bu, güvenlik açısından imajların otomatik olarak taranmasını sağlar.**

</details>


<details>
<summary><strong>iamRole.tf Dosyası Detayları</strong></summary>

### AWS IAM Rolü ve Politika Konfigürasyonu
AWS IAM hizmetini kullanarak bir IAM rolü ve bu role bağlı bir politika oluşturur.

### IAM Rolü (aws_iam_role)

- **Amaç:** Amazon ECS görevlerinin çalıştığı servis tarafından kullanılan bir IAM rolü oluşturmak.
- **Özellikler:**
  - `name`: IAM rolünün adı ("ecsTaskExecutionRole").
  - `assume_role_policy`: Rolün alım politikasını belirlemek için bir JSON belgesi kullanır.

### IAM Politika Belgesi (data "aws_iam_policy_document")

- **Amaç:** IAM rolüne atanacak alım politikasını belirlemek.
- **Özellikler:**
  - `statement`: IAM politika belgesinin bir ifadesini belirtir.
    - `actions`: Yapılacak eylemleri belirtir ("sts:AssumeRole").
    - `principals`: Bu rolu kullanabilecek servis veya kullanıcı türünü belirtir.
      - `type`: "Service" (Servis).
      - `identifiers`: Rolu kullanabilecek servisin tanımlayıcıları ("ecs-tasks.amazonaws.com").

### IAM Rolü Politika Eki (aws_iam_role_policy_attachment)

- **Amaç:** IAM rolüne belirli bir politikayı eklemek.
- **Özellikler:**
  - `role`: Politika eklenen IAM rolünün adı.
  - `policy_arn`: Eklenen politikanın Amazon kaynak numarası (ARN) ("arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy").

**Amazon ECS görevlerinin belirli eylemleri gerçekleştirmesi için kullanılan bir IAM rolü oluşturur. `assume_role_policy` belgesi, bu rolu kullanabilecek servisi tanımlar. Ardından, `AmazonECSTaskExecutionRolePolicy` adlı AWS tarafından sağlanan önceden tanımlanmış bir politika IAM rolüne eklenir. Bu politika, Amazon ECS görevlerinin çalıştığı ortamda gerekli yetkilere sahip olmalarını sağlar.**



  
</details>
</div>
