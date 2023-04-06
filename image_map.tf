locals {
  bootstrap_image_region_map = {
    "hpcc-scale-bootstrap-v2-1-1" = {
      "eu-gb"    = "r018-eee27e93-cb4d-478c-8310-b2ca3a7f18ee"
      "eu-de"    = "r010-7750d93e-6579-46dc-8ce8-10576385f6e1"
      "us-east"  = "r014-41f905f5-a92f-456d-9bc5-517bdf272bf1"
      "us-south" = "r006-791609ff-6688-450a-8bbc-004fdda3dd7d"
      "jp-tok"   = "r022-257a1dcb-4dbc-4e0f-876a-782ce44a9647"
      "jp-osa"   = "r034-005dffa1-186d-489b-8113-ced6f078339e"
      "au-syd"   = "r026-c91e0bde-e3a4-4ea8-92cd-fcebe42eacc4"
      "br-sao"   = "r042-f628b2ae-6c92-4db0-afee-1240f83f4e57"
      "ca-tor"   = "r038-6a3dd36a-0c4b-43ff-9f74-125e90cb2ad8"
    }
  }
  compute_image_region_map = {
    "hpcc-scale5141-rhel79-v2-1-1" = {
      "eu-gb"    = "r018-cebfced1-69d8-48a6-af9a-cc1f6641fd97"
      "eu-de"    = "r010-67ef85d9-0343-4eda-a753-ea25dcbd34de"
      "us-east"  = "r014-689ec249-85b5-41ee-970b-bb1209843bd0"
      "us-south" = "r006-9749d983-e921-44ec-91bf-a7f2ebc3eae4"
      "jp-tok"   = "r022-3a846e4c-c1c2-4170-9806-3949b7965af8"
      "jp-osa"   = "r034-809dbcf8-0b97-48b0-ac36-573a8332f59e"
      "au-syd"   = "r026-6d1dfe21-7107-407a-a524-d156100a5914"
      "br-sao"   = "r042-2f47777b-b6c7-4571-97a4-25b67b8e28e5"
      "ca-tor"   = "r038-74c6a0ce-4937-4b9b-8a12-6e2563f76a64"
    }
    "hpcc-scale5141-rhel84-v2-1-1" = {
      "eu-gb"    = "r018-9e06008c-c923-4f1a-aba9-69c7a441978a"
      "eu-de"    = "r010-82b794a8-42b7-4683-b898-732e227bdc8a"
      "us-east"  = "r014-5ab21c86-3957-4e44-bfed-f5eae1a92182"
      "us-south" = "r006-a5241296-8e73-4b64-b206-5c5b90743ec7"
      "jp-tok"   = "r022-a01c1e19-21b9-493c-bc54-2eb6ceff5165"
      "jp-osa"   = "r034-cd1eac8d-d6a0-4457-9500-107801504ed9"
      "au-syd"   = "r026-c0c706db-72f9-4941-9e1d-86ad491f9521"
      "br-sao"   = "r042-8c127c2b-c072-4776-a57f-64225a8a7cf3"
      "ca-tor"   = "r038-81916037-ff8e-4c5b-b734-82df70c6b2d1"
    }
  }
  storage_image_region_map = {
    "hpcc-scale5141-rhel84-v2-1-1" = {
      "eu-gb"    = "r018-9e06008c-c923-4f1a-aba9-69c7a441978a"
      "eu-de"    = "r010-82b794a8-42b7-4683-b898-732e227bdc8a"
      "us-east"  = "r014-5ab21c86-3957-4e44-bfed-f5eae1a92182"
      "us-south" = "r006-a5241296-8e73-4b64-b206-5c5b90743ec7"
      "jp-tok"   = "r022-a01c1e19-21b9-493c-bc54-2eb6ceff5165"
      "jp-osa"   = "r034-cd1eac8d-d6a0-4457-9500-107801504ed9"
      "au-syd"   = "r026-c0c706db-72f9-4941-9e1d-86ad491f9521"
      "br-sao"   = "r042-8c127c2b-c072-4776-a57f-64225a8a7cf3"
      "ca-tor"   = "r038-81916037-ff8e-4c5b-b734-82df70c6b2d1"
    }
  }
  evaluation_image_region_map = {
    "hpcc-scale514-rhel84-v2-1-1" = {
      "eu-gb"    = "r018-d3bcb53b-8697-4e9a-9e02-727c3fd28bc3"
      "eu-de"    = "r010-849f8aff-fab7-4699-9444-ef3dbbdc0ee2"
      "us-east"  = "r014-f1f7307f-8e7f-49e4-8e32-3ccfe3ee9c74"
      "us-south" = "r006-cea549cd-5ee9-4188-8a4a-970c24725e40"
      "jp-tok"   = "r022-b82fa2b0-d276-42e3-a5c9-735ec798055f"
      "jp-osa"   = "r034-ceabd091-4848-4e96-9667-778330c9dc3c"
      "au-syd"   = "r026-d4c8b235-2ce8-4e59-8722-f7e4e88ee264"
      "br-sao"   = "r042-2f94763a-8a43-4f0b-86d5-857ffe291fdb"
      "ca-tor"   = "r038-07fc67ca-67e3-434c-b5d2-c6419b85af92"
    }
  }
}