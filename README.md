# RegionSystem

![Region banner preview](docs/region-banner.jpg)

Roblox için oyuncuya özel bölge sistemi. Giriş ve çıkış bildirimleri ekranın üst orta bölümünde, şeffaf arka planla gösterilir. Büyük bölge adının altında, iki yana uzanan düz çizgilerin ortasında 45 derece döndürülmüş kare biçiminde bir elmas bulunur; açıklama bu ayırıcının altındadır. Hazır ekran metinleri İngilizcedir. Giriş müziği, çıkış müziği, bölge içinde döngüde çalan tema ve özel Lighting ayarları birbirinden bağımsız açılıp kapatılabilir.

## Kurulum

- `ReplicatedStorage.RegionSystem`: `src/RegionSystem/init.luau` içeriğini taşıyan **ModuleScript**.
- `ReplicatedStorage.RegionSystem.Config`: `src/RegionSystem/Config.luau` içeriğini taşıyan, ana modülün altındaki **ModuleScript**.
- `ReplicatedStorage.RegionSystem.Audio`: `src/RegionSystem/Audio.model.json` içindeki yapıya ve özelliklere göre oluşturulan ses klasörü; içindeki şablonlar **Sound** nesneleridir.
- `StarterPlayer.StarterPlayerScripts.RegionClient`: `src/RegionClient.client.luau` içeriğini taşıyan **LocalScript**.
- `Workspace.Regions`: Studio'da oluşturacağın bölge parçalarını içeren klasör. Alt klasörlerdeki `BasePart` nesneleri de taranır.

Her bölge parçasına **String** türünde `RegionId` attribute'u ekle. Hazır ayarlar için değeri `Green`, `Yellow` veya `Red` yap. Parçanın adı önemli değildir; ekranda gösterilen ad Config içindeki `Name` alanıdır. Aynı `RegionId` değerini kullanan parçalar tek bölge sayılır. Bir parçayı kapatmak için ona **Boolean** türünde `Enabled = false` attribute'u ekle; açmak için `true` yap veya attribute'u kaldır.

Görünmez ve içinden geçilebilir alanlar için parçaları `Anchored = true`, `CanCollide = false`, `Transparency = 1` yapabilirsin. `RegionId` yoksa parça bağımsız bir bölge olur ve `Defaults` kullanılır. Config'de karşılığı olmayan ID'ler de `Defaults` kullanır.

`default.project.json`, kodu ve ses şablonlarını bu Studio yollarına eşleyen isteğe bağlı Rojo proje dosyasıdır. Bölge parçalarını içermez; onları Studio'da oluştur.

## Ayarlar

`Config.Regions.Green` gibi bir bölge kaydını düzenle veya yeni bir anahtar ekleyip parçalara aynı `RegionId` değerini ver:

```lua
Green = {
    Name = "Green Region",
    Description = "A quiet corner beneath the trees.",
    Priority = 0,
    Intro = { Enabled = true, Duration = 2.4 },
    Outro = { Enabled = true, Duration = 1.6 },
    IntroMusic = { Enabled = true },
    OutroMusic = { Enabled = true },
    Theme = { Enabled = false },
    Lighting = {
        Enabled = true,
        ClockTime = 9,
        Brightness = 2,
        Ambient = Color3.fromRGB(90, 115, 95),
    },
}
```

`Intro` ve `Outro` ekran bildirimleridir; müzikleri ayrı alanlarla yönetilir. Her özellikte `Enabled = false` kullanabilir veya özelliği tamamen `false` yapabilirsin: `Theme = false`, `Lighting = false`, `Intro = false` gibi. Bir alanı kaldırmak onu kapatmaz; `Defaults` değerine döndürür. İç içe tablolar birleştirilmez.

Lighting için `Ambient`, `OutdoorAmbient`, `Brightness`, `ClockTime`, `FogColor`, `FogStart`, `FogEnd`, `ExposureCompensation`, `ColorShift_Top` ve `ColorShift_Bottom` desteklenir. Bölgeden çıkınca değiştirilen değerler eski haline döner. `LightingTransition` ışık geçişini saniye olarak belirler.

Bildirimde başlık ve açıklama kısa bir arayla kayarak belirir; elmas büyüyüp dönerken çizgiler merkezden dışarı uzar. Kapanışta çizgiler merkeze toplanır ve yazılar kaybolur. Çıkış bildiriminde kayma ve dönüş yönü tersine döner. `FadeTime`, bu Tween animasyonlarının açılış ve kapanış sürelerini saniye olarak belirler; `0` yapıldığında geçiş anlık olur. Yeni bir bölge geçişi önceki bildirimin animasyonlarını iptal eder.

## Sesler

Sesleri Explorer'da doğrudan modülün altından düzenle:

```text
ReplicatedStorage.RegionSystem.Audio
├─ Default
│  ├─ Intro (Sound)
│  ├─ Outro (Sound)
│  └─ Theme (Sound)
├─ Green
│  ├─ Intro (Sound)
│  ├─ Outro (Sound)
│  └─ Theme (Sound)
├─ Yellow
│  ├─ Intro (Sound)
│  ├─ Outro (Sound)
│  └─ Theme (Sound)
└─ Red
   ├─ Intro (Sound)
   ├─ Outro (Sound)
   └─ Theme (Sound)
```

`Default`, `Green`, `Yellow` ve `Red` birer **Folder** nesnesidir. Bölge klasörünün adı `RegionId` ile eşleşir. İstediğin Sound nesnesinin `SoundId`, `Volume` ve `PlaybackSpeed` özelliklerini Properties üzerinden değiştir; ses efektlerini de bu nesnenin altına ekleyebilirsin. Kendi seslerin için deneyimin kullanma izni olan Roblox varlıklarını kullan.

Bölgesel sesin `SoundId` alanı boşsa aynı türdeki `Default` sesi kullanılır: örneğin `Green.Intro` boşken `Default.Intro` devreye girer. Hazır ayarda `Default.Intro` ve `Default.Outro` için ses atanmıştır; Config'de giriş ve çıkış müzikleri açıktır. Yellow bölgesinin tema sesi atanmış ve açıktır; diğer bölgelerin temaları kapalıdır. Tema eklemek için bölgenin veya `Default` klasörünün `Theme.SoundId` alanını doldurup Config'de ilgili `Theme.Enabled` değerini `true` yap.

Config'deki `IntroMusic.Enabled`, `OutroMusic.Enabled` ve `Theme.Enabled` yalnızca açma/kapamayı yönetir. Geriye uyumluluk için Config'de açıkça verilen `Volume`, oynatma sesinin düzeyini değiştirir. Config'de dolu bir `SoundId` verilirse şablondan bağımsız bir Sound oluşturulur; şablonun efektleri ve `PlaybackSpeed` değeri bu eski kullanımda aktarılmaz.

Modül seçilen Sound şablonunu efektleri ve ses özellikleriyle birlikte `SoundService` içine kopyalar; modül altındaki asılları oynatmaz veya değiştirmez. Giriş ve çıkış sesleri tek seferliktir; tema yalnızca içeride döngüde çalar. Geçişte önceki oynatma kopyaları temizlenir. Tek seferlik seslerde temizlik sınırı 120 saniyedir.

## Çalışma ve API

Varsayılan `CheckInterval = 0.1` ile karakterin gövde parçalarının bölge hacmiyle teması kontrol edilir. Aksesuarlar ve eldeki araçlar tetiklemez. Aynı bölge içinde giriş tekrarlanmaz; tamamen çıkıp tekrar girince yeniden tetiklenir. Birden fazla bölgeyle temas varsa en yüksek `Priority` seçilir. Eşit öncelikte mevcut bölge korunur. Doğrudan bölge değişiminde önce eski bölgenin çıkış bildirimi, ardından yenisinin giriş bildirimi gösterilir.

Efektler her oyuncunun kendi istemcisinde çalışır. Bu görsel ve işitsel davranışlar için RemoteEvent gerekmez. Modül istemcide yüklendiğinde `Entered` ve `Exited` adlı **BindableEvent** nesneleri `ReplicatedStorage.RegionSystem` altında oluşturulur; sunucuya veya diğer oyunculara iletilmez.

Bir LocalScript içinden:

```lua
local RegionSystem = require(game:GetService("ReplicatedStorage"):WaitForChild("RegionSystem"))

RegionSystem.Entered.Event:Connect(function(regionId, config, part)
    print("Entered", regionId, config.Name, part)
end)

RegionSystem.Exited.Event:Connect(function(regionId, config, part)
    print("Exited", regionId, config.Name, part)
end)

RegionSystem.Start()
```

Hazır `RegionClient` zaten `Start()` çağırır. `GetCurrentRegion()` aktif bölge için `regionId, config, part`, dışarıdaysa `nil` döndürür. `Stop()` taramayı durdurur, arayüzü ve sesleri temizler, ışığı geri yükler; tekrar `Start()` çağrılabilir. Ölümde efektler temizlenir ve yeniden doğuşta tarama devam eder.

## Test

`tests/RegionSystem.spec.luau`, Play modunda bir LocalScript üzerinden çalıştırılan 27 kontrol içerir. Giriş/çıkış, bölge önceliği, döndürülmüş parçalar, ortak kimlik, ışığın geri yüklenmesi, ses yaşam döngüsü, kapatma ve yeniden başlatma denetlenir. Ses testleri Roblox'un yerleşik seslerini sıfır ses düzeyinde kullanır; kendi müziklerinin deneyim izinlerini ayrıca doğrula.

Test dosyasını `ReplicatedStorage.RegionSystemTest` adlı bir ModuleScript'e aktar. Bir test LocalScript'inde çalıştır:

```lua
local run = require(game:GetService("ReplicatedStorage").RegionSystemTest)
local result = run()
print(result.passed, result.failure)
```

Test sırasında karakter geçici olarak taşınır; sonunda konumu, ayarlar ve oluşturulan test parçaları temizlenir. Testi Studio Play oturumunda çalıştır; test ModuleScript'ini ve çağıran LocalScript'i yayımlanacak oyuna ekleme.
