'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "d3ab0f3ecdcbb4abe05e4ecfd6bdbfe2",
"version.json": "b8cc936acc7770c6a7edf2952b2c32b9",
"index.html": "aa08f59a45ac820729b622cf113f04fe",
"/": "aa08f59a45ac820729b622cf113f04fe",
"main.dart.js": "fbe55fbfee459f4139ff32aa63594463",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"favicon.png": "eea1b1e4c52d4952bf6068ccbff93078",
"icons/Icon-192.png": "e81de1380aa1aa19d907817146c853fb",
"icons/Icon-maskable-192.png": "e81de1380aa1aa19d907817146c853fb",
"icons/Icon-maskable-512.png": "1802e95bf686214ef10dde5fd2787adb",
"icons/Icon-512.png": "1802e95bf686214ef10dde5fd2787adb",
"manifest.json": "ed23df1b2269ca32935b105af4521ab7",
"assets/AssetManifest.json": "69449e241f3b40b1905a681edf731b38",
"assets/NOTICES": "965cfbd634dd807c34d1413ab165965b",
"assets/FontManifest.json": "571313f5afb35c3ecb9586e02b7f9cd3",
"assets/AssetManifest.bin.json": "bd29322f9b403e681fe9176c5bb2ec84",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/any_link_preview/lib/assets/giphy.gif": "b0db8189c4cfba8340d61b1e72b1acdc",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "bba51282469726b453c136fd7fb8ed76",
"assets/fonts/MaterialIcons-Regular.otf": "7a8a602ccac5f20cfd87ab93388d52d0",
"assets/assets/images/logo-removebg.png": "32d04f23d75afef268823bd2f7307cc6",
"assets/assets/images/logo-new.png": "23179757b5eae2640b2ac5b3f0a03790",
"assets/assets/emojis/cat/cat-wink.png": "ff44cab588970e41edcc871f976e3620",
"assets/assets/emojis/cat/cat-angry.png": "9b7d056a45d217fc595dd9ee979e8bbc",
"assets/assets/emojis/cat/cat-love.png": "a5b356204db4798fd6a59acd32d54a52",
"assets/assets/emojis/cat/cat-wow.png": "7891e672efea726e8a028e5c6d3cc0b8",
"assets/assets/emojis/cat/cat-haha.png": "b6d081151c30e4ff4404fd2a107f4462",
"assets/assets/emojis/cat/cat-sad.png": "40437e93a66646963e87e68e2a2b4d26",
"assets/assets/emojis/cat/cat-fire.png": "5807d3df01cbd0df6c7004f8f74bb9b2",
"assets/assets/emojis/man/man-wink.png": "2c337e7516bc7763e679c95732074744",
"assets/assets/emojis/man/man-wow.png": "e8bd98f024f7e4c25068806abdbdb84b",
"assets/assets/emojis/man/man-angry.png": "eb0f6d2068ea7a64e6f143e285010f4a",
"assets/assets/emojis/man/man-love.png": "57c38b47e7bc6fc6ee0b174070c373ba",
"assets/assets/emojis/man/man-haha.png": "b0de9b3a37b5db13e72d89e32dd3f114",
"assets/assets/emojis/man/man-fire.png": "5807d3df01cbd0df6c7004f8f74bb9b2",
"assets/assets/emojis/man/man-sad.png": "b8e5be71d6e861dd5c0a96e4796243eb",
"assets/assets/emojis/face-funny/face-funny-fire.png": "83f690c946fdcf3268a71e12848b7329",
"assets/assets/emojis/face-funny/face-funny-haha.png": "3f2d3a4bae39c33464b9d49567b28b60",
"assets/assets/emojis/face-funny/face-funny-sad.png": "a4ed3da8ad80e728c1fcfbc42dbe2d08",
"assets/assets/emojis/face-funny/face-funny-love.png": "44d435e4f47daad53e3d5323fd73da1d",
"assets/assets/emojis/face-funny/face-funny-wow.png": "9054d9221bd2e3a5e06fa5935f149f72",
"assets/assets/emojis/face-funny/face-funny-wink.png": "20c5fc003d7ea4070f437fe9650b3de1",
"assets/assets/emojis/face-funny/face-funny-angry.png": "01bfb4363cddd007856c5fa90be61289",
"assets/assets/emojis/face-linear/face-linear-sad.png": "cf432ba73cf8495771b723e0fc74b767",
"assets/assets/emojis/face-linear/face-linear-love.png": "0d981e6d26c2e3854355ae1d73f47de5",
"assets/assets/emojis/face-linear/face-linear-wink.png": "9b7b7924794f7e6fa13d8cb05c72601c",
"assets/assets/emojis/face-linear/face-linear-angry.png": "d5a100c87af68e753d8d017a6e88f186",
"assets/assets/emojis/face-linear/face-linear-wow.png": "13f8d13a6a04a3e2a9c970ae48c74a7c",
"assets/assets/emojis/face-linear/face-linear-fire.png": "0f5d4cd3664a00217a3934f10e29cf7c",
"assets/assets/emojis/face-linear/face-linear-haha.png": "79d92b3a57a9167d7a54f8e1e5e58cba",
"assets/assets/emojis/dog/dog-fire.png": "5807d3df01cbd0df6c7004f8f74bb9b2",
"assets/assets/emojis/dog/dog-angry.png": "b7621c5f842cfb3d65ef5379f683ea59",
"assets/assets/emojis/dog/dog-haha.png": "1e7395446dce29db8d920160cda6b054",
"assets/assets/emojis/dog/dog-wow.png": "15e50c2c909630a1872d7a92fa1112a7",
"assets/assets/emojis/dog/dog-sad.png": "89e29fd7e8722abd89030ca949692813",
"assets/assets/emojis/dog/dog-love.png": "d766a13253c5a1d828cc0c4bf0128572",
"assets/assets/emojis/dog/dog-wink.png": "2520e85adc7af928a80c968122613dcd",
"assets/assets/emojis/face-fill/face-fill-sad.png": "702b81c76dc96e613ac8bba63ab43990",
"assets/assets/emojis/face-fill/face-fill-fire.png": "3912e8d4a6e4b66ce317d14ab69f40db",
"assets/assets/emojis/face-fill/face-fill-haha.png": "bec68b6c4cc1dd6981c15e327bda6c6c",
"assets/assets/emojis/face-fill/face-fill-love.png": "efa322393b6c9feed26538673a41288b",
"assets/assets/emojis/face-fill/face-fill-angry.png": "e41aab8b49e128aef402e93d63be83fa",
"assets/assets/emojis/face-fill/face-fill-wink.png": "e80562347aa6c3a8adc7bf31326f6e0e",
"assets/assets/emojis/face-fill/face-fill-wow.png": "d547f27d72bff578fcb6523396a1b7dd",
"assets/assets/emojis/face-3d/face-3d-wink.png": "38b7a280a0393194ca16c5480c591ed4",
"assets/assets/emojis/face-3d/face-3d-love.png": "da9ad58ecf3b4a6e1dd9e17c28d41558",
"assets/assets/emojis/face-3d/face-3d-wow.png": "dca076cfceb2521e608779bf8206db6c",
"assets/assets/emojis/face-3d/face-3d-haha.png": "07091d8c737d4e22f42d918e5e793ccb",
"assets/assets/emojis/face-3d/face-3d-sad.png": "9d91da3bb15e641a6300ffb2fb939a05",
"assets/assets/emojis/face-3d/face-3d-fire.png": "f17bec4c539380558126d1eb9479a5c1",
"assets/assets/emojis/face-3d/face-3d-angry.png": "3979cf46c139385798bb58ebeccbb314",
"assets/assets/emojis/face-outline/face-outline-angry.png": "6b161e562f1eface8fbf3f33a54cd807",
"assets/assets/emojis/face-outline/face-outline-haha.png": "d7d37b86651574e26b7c7e8436e94c98",
"assets/assets/emojis/face-outline/face-outline-fire.png": "3a62226082bf560097c87bf36b27a1bb",
"assets/assets/emojis/face-outline/face-outline-wow.png": "f7c636d3bdc5c31a6bafd2287d50c4c3",
"assets/assets/emojis/face-outline/face-outline-wink.png": "7b3ea6bc276234566b72387f5785394c",
"assets/assets/emojis/face-outline/face-outline-sad.png": "9f0d9a8357704da42178c5d3b35311ab",
"assets/assets/emojis/face-outline/face-outline-love.png": "623665c6697f3b9ce0f98a730160fb8d",
"assets/assets/emojis/woman/woman-sad.png": "ac07ebb2a461ce0a6e18d44a7344b36d",
"assets/assets/emojis/woman/woman-angry.png": "3d6bffb4ffe365c3791ce20d0148607c",
"assets/assets/emojis/woman/woman-fire.png": "5807d3df01cbd0df6c7004f8f74bb9b2",
"assets/assets/emojis/woman/woman-haha.png": "19cf0264515928c93b5e1378a836974d",
"assets/assets/emojis/woman/woman-love.png": "179f38c5e3dc45042f280b8773d1b56c",
"assets/assets/emojis/woman/woman-wow.png": "96f2b09230aa6fc8d6564bc91261dba7",
"assets/assets/emojis/woman/woman-wink.png": "54d27ab47ca995341d8c6b216f66a36f",
"assets/assets/fonts/nunito/Nunito-Medium.ttf": "d26cecc95cdc8327b337357e6c5c1f5b",
"assets/assets/fonts/nunito/Nunito-Light.ttf": "7de99c591b88e33ceda578f9ee140263",
"assets/assets/fonts/nunito/Nunito-Regular.ttf": "b83ce9c59c73ade26bb7871143fd76bb",
"assets/assets/fonts/nunito/Nunito-SemiBold.ttf": "38257ec36f55676f98fcdf1264adb69d",
"assets/assets/fonts/nunito/Nunito-Bold.ttf": "ba43cdecf9625c0dcec567ba29555e15",
"assets/assets/fonts/nunito/Nunito-Black.ttf": "27ee28fd596c0bd4235fa792d0d8b1ce",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
