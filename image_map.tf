locals {
  bootstrap_image_region_map = {
    "hpcc-scale-bootstrap-v2-3" = {
      "eu-gb"    = "r018-c07e3bb5-5d72-4fd5-b3ec-29e11bde59de"
      "eu-de"    = "r010-79e5da70-b17b-49e0-9e24-7c45f39fedf1"
      "us-east"  = "r014-26df3504-ab21-4c2f-9e7b-0e96d2c606f8"
      "us-south" = "r006-7fe0b5f5-aef7-4527-a530-53ca5d8a9af9"
      "jp-tok"   = "r022-cd140fd0-681d-414c-b41a-59775821a1ff"
      "jp-osa"   = "r034-340ebbcc-bff5-4b9d-897b-2efbcd97df40"
      "au-syd"   = "r026-1c54bae1-80f4-4068-997d-896cac844e8d"
      "br-sao"   = "r042-d4581d38-ce33-400c-99a9-90b5bd2b651f"
      "ca-tor"   = "r038-9a894921-d80e-4f28-a8ec-dfe781908060"
    }
  }
  compute_image_region_map = {
    "hpcc-scale5190-rhel79" = {
      "eu-gb"    = "r018-c80f060e-a9f9-48c5-97c7-cbfae6ee8788"
      "eu-de"    = "r010-ba257f36-26a5-43b0-beea-34dba937dfdf"
      "us-east"  = "r014-33aa4e32-1012-4ef4-a42a-22e09ae4093c"
      "us-south" = "r006-a4902668-aa2c-4389-86bc-0c8c445a9f9a"
      "jp-tok"   = "r022-8a4fdaff-5e2e-400d-bd34-41db5fc2ccf1"
      "jp-osa"   = "r034-351e07f2-ef5a-4ab0-aa7d-dd74278a32ce"
      "au-syd"   = "r026-2334a14f-498b-4fa6-88d0-127d7900567a"
      "br-sao"   = "r042-b39ee453-e9d4-4cd7-855c-5f8fc8d2cd23"
      "ca-tor"   = "r038-e1eef48d-1674-4d77-8627-51d79b8288f3"
    }
    "hpcc-scale5190-rhel88" = {
      "eu-gb"    = "r018-c5ae35fb-0c03-4321-a8b0-f8059ac85958"
      "eu-de"    = "r010-648cdd71-864c-44a3-9f89-f7e2016ee03b"
      "us-east"  = "r014-c4e311f4-e456-4150-a6b4-2801276f3621"
      "us-south" = "r006-03d541b0-9036-4bf2-a8c5-588b7415742b"
      "jp-tok"   = "r022-91e379ad-17e8-415b-b9db-029149e03460"
      "jp-osa"   = "r034-ea039080-885b-44cb-8665-244e8bce9d6a"
      "au-syd"   = "r026-d282afc4-5dfd-41e5-a859-e84b49641531"
      "br-sao"   = "r042-799c1df2-b966-481a-a100-17727be19328"
      "ca-tor"   = "r038-17499e7e-3a7a-4c9e-85ab-149ff604c66f"
    }
  }
  storage_image_region_map = {
    "hpcc-scale5190-rhel88" = {
      "eu-gb"    = "r018-c5ae35fb-0c03-4321-a8b0-f8059ac85958"
      "eu-de"    = "r010-648cdd71-864c-44a3-9f89-f7e2016ee03b"
      "us-east"  = "r014-c4e311f4-e456-4150-a6b4-2801276f3621"
      "us-south" = "r006-03d541b0-9036-4bf2-a8c5-588b7415742b"
      "jp-tok"   = "r022-91e379ad-17e8-415b-b9db-029149e03460"
      "jp-osa"   = "r034-ea039080-885b-44cb-8665-244e8bce9d6a"
      "au-syd"   = "r026-d282afc4-5dfd-41e5-a859-e84b49641531"
      "br-sao"   = "r042-799c1df2-b966-481a-a100-17727be19328"
      "ca-tor"   = "r038-17499e7e-3a7a-4c9e-85ab-149ff604c66f"
    }
  }
  evaluation_image_region_map = {
    "hpcc-scale519-rhel88" = {
      "eu-gb"    = "r018-ff4f0a6a-81e5-4882-a083-46e5f02fecf1"
      "eu-de"    = "r010-13991f86-a497-4176-804e-b7fda6b5c01c"
      "us-east"  = "r014-15d75493-d871-4a28-a8bb-be28b5385eef"
      "us-south" = "r006-3e547322-a8bc-4e12-9f90-d37e57ebe654"
      "jp-tok"   = "r022-9a6ddb5d-6ea5-4433-a686-20bce5f7a84e"
      "jp-osa"   = "r034-24eb62d1-d463-405c-bacd-87a76c87c402"
      "au-syd"   = "r026-8f844ae6-0f77-4eb5-a821-83cdf10e6c03"
      "br-sao"   = "r042-b3bceb67-631e-43a1-84df-200698b72776"
      "ca-tor"   = "r038-fdcaaad8-b7e9-45df-ac88-e4356c1cb687"
    }
  }
  scale_encryption_image_region_map = {
    "hpcc-scale-gklm-v4-2-0-2" = {
      "eu-gb"    = "r018-adc5f634-d3c8-4327-9468-9a82a82125de"
      "eu-de"    = "r010-16bc3f93-d4b2-4387-813a-88e347bf876e"
      "us-east"  = "r014-9da755dc-51cd-46f8-9197-12da8095972d"
      "us-south" = "r006-e7f0bd50-454e-469b-9bb8-164cd2162f37"
      "jp-tok"   = "r022-2aa34902-30ef-4113-bd8c-3f480a780b2a"
      "jp-osa"   = "r034-98f74bf4-f901-4380-8e61-61cf217a0f95"
      "au-syd"   = "r026-61c2e1e3-8de9-4ccb-95c9-054474c16b9e"
      "br-sao"   = "r042-5196b96d-1f2b-4832-9bfa-f6bd6b9a7f8d"
      "ca-tor"   = "r038-5d4119f3-15f5-40c7-9675-9783fc077c19"
    }
  }
}
