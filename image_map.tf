locals {
  bootstrap_image_region_map = {
    "hpcc-scale-bootstrap-v2-1" = {
      "eu-gb"    = "r018-fbda70ca-4afb-4c42-8720-4fb4a32cace1"
      "eu-de"    = "r010-9fcfb8a8-2b09-4a35-927d-660bef43b829"
      "us-east"  = "r014-2a6e1789-7efc-4be5-977f-e281a789e34b"
      "us-south" = "r006-9a128ad5-34fc-448c-ae33-68467bc3e8a0"
      "jp-tok"   = "r022-061f8182-99cf-407d-afc7-5f518f1870d7"
      "jp-osa"   = "r034-a276a14e-a326-40ca-80fc-5251881f81a7"
      "au-syd"   = "r026-0e9c9d64-73b3-4505-b843-507e17159613"
      "br-sao"   = "r042-d73d2890-3401-4c84-91b9-79b953ad3ce4"
      "ca-tor"   = "r038-7b11c11d-80aa-4f95-a8e0-2a37b41a1e57"
    }
  }
  compute_image_region_map = {
    "hpcc-scale5141-rhel79-v2-1" = {
      "eu-gb"    = "r018-146b2f85-602e-40c4-a9c2-24b8fda3625c"
      "eu-de"    = "r010-057583c8-a60e-4f9d-9b99-bf9febff1e27"
      "us-east"  = "r014-e47616d4-19b7-43d0-a5a9-daee5f05f56c"
      "us-south" = "r006-e5272f3e-da4c-45bb-b461-c92d5a69a74a"
      "jp-tok"   = "r022-fc116cac-93a6-4b4f-b7bb-9abdc9d36023"
      "jp-osa"   = "r034-90d398d7-a7b6-4124-980e-e17e5872b2f2"
      "au-syd"   = "r026-abea94a1-a0e3-4796-ab32-908bf125fa10"
      "br-sao"   = "r042-78285b67-3fb9-4048-b00e-e6ef67dafb86"
      "ca-tor"   = "r038-9fd6acb0-e4c9-45c1-91f1-83408d6f44dc"
    }
    "hpcc-scale5141-rhel84-v2-1" = {
      "eu-gb"    = "r018-80e9ce91-ff16-4caa-8769-ed0d73d39cc4"
      "eu-de"    = "r010-f5ea626f-2321-4a4e-aaef-78ca58894a03"
      "us-east"  = "r014-bda4a60b-8a22-46cb-83df-e1f3f894c255"
      "us-south" = "r006-d2092f30-3f79-403d-9ec9-506fb6227fd4"
      "jp-tok"   = "r022-cd2020e7-d95f-43d7-ae09-afa2c9c68c32"
      "jp-osa"   = "r034-1652af04-4e72-45fb-8236-4c52e8938034"
      "au-syd"   = "r026-a84b011e-6bff-464a-bb5b-62dcdd04b8d9"
      "br-sao"   = "r042-97d4aed6-3d9a-4446-aef0-8f3925692b76"
      "ca-tor"   = "r038-c8f22882-c6e9-4f85-b821-9b78e888bbeb"
    }
  }
  storage_image_region_map = {
    "hpcc-scale5141-rhel84-v2-1" = {
      "eu-gb"    = "r018-80e9ce91-ff16-4caa-8769-ed0d73d39cc4"
      "eu-de"    = "r010-f5ea626f-2321-4a4e-aaef-78ca58894a03"
      "us-east"  = "r014-bda4a60b-8a22-46cb-83df-e1f3f894c255"
      "us-south" = "r006-d2092f30-3f79-403d-9ec9-506fb6227fd4"
      "jp-tok"   = "r022-cd2020e7-d95f-43d7-ae09-afa2c9c68c32"
      "jp-osa"   = "r034-1652af04-4e72-45fb-8236-4c52e8938034"
      "au-syd"   = "r026-a84b011e-6bff-464a-bb5b-62dcdd04b8d9"
      "br-sao"   = "r042-97d4aed6-3d9a-4446-aef0-8f3925692b76"
      "ca-tor"   = "r038-c8f22882-c6e9-4f85-b821-9b78e888bbeb"
    }
  }
  evaluation_image_region_map = {
    "hpcc-scale514-rhel84-v2-1" = {
      "eu-gb"    = "r018-80e9ce91-ff16-4caa-8769-ed0d73d39cc4"
      "eu-de"    = "r010-95c7b3a0-f6e3-4d8a-b86c-1dac4b4c08f5"
      "us-east"  = "r014-e2f09c1f-d82d-4f85-aeed-e54cb88d5d67"
      "us-south" = "r006-762eda69-de24-4867-8cb6-dbac35ceb347"
      "jp-tok"   = "r022-5ae66db4-1a8b-46f6-bc08-47ab80577db5"
      "jp-osa"   = "r034-7e5fa80f-a3bf-4da3-ab8d-f62ba0c9392d"
      "au-syd"   = "r026-c2ceb9b1-f092-4a47-8f25-594ce0c6ad6f"
      "br-sao"   = "r042-0f7426b7-bd3c-4463-97da-fe7d23629852"
      "ca-tor"   = "r038-ba978f13-f073-4bcd-809e-810d67fe0860"
    }
  }
}