### 1. AŞAMA - Uygulamayı Derleme ###

# Esas imajı çek ve etiketle
FROM node:14-slim as development

# Çalışma dizinini ayarla
WORKDIR /app

# package.json dosyalarını çalışma dizinine kopyala
# bağımlılıkları yüklemek üzere kullanmak için.
COPY package*.json ./

# Uygulama bağımlılıklarını yükler.
RUN npm install

# Uygulama kaynak kodlarını kopyalar.
# kaynak kodlarını derlemek üzere konteyner içerisine kopyalama işlemi.
COPY . .

# React uygulamasının üretim sürümünü oluşturur.
## kaynak kodlarını derleyip nihai versiyonunu alacağız.
RUN npm run build



### 2. AŞAMA - Uygulamayı Hizmete Sunma ###

# Esas imajı çek ve etiketle
# burada caddy ve benzeri web sunucuları veya node.js alt yapısını kullanabilirdik
# isterlere göre en düşük imaj boyutu bu şekilde elde edildiği için daha hafif olan 'nginx' kullandık.
FROM nginx:alpine AS production

#Çalışma dizinini ayarla
WORKDIR /app

# 'development' ile etiketli aşama içerisinden derlenen dosya ve paketlerini kopyalar.
# Nginx web sunucusu içerisinde ilgili dizine bu dosyaları yerleştirir.
COPY --from=development /app/build /usr/share/nginx/html/

# uygulamanın 80 portunu dış dünyaya açar.
EXPOSE 80

# Web sunucusunu başlat.
CMD ["nginx", "-g", "daemon off;"]
