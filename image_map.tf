locals {
  bootstrap_image_region_map = {
    "hpcc-scale-bootstrap-v1" = {
      "eu-gb"    = "r018-2eff3255-fb0c-4e39-9da1-d97d1ed64ab2"
      "eu-de"    = "r010-6f286e6e-8d81-4345-ba16-745bc92f7596"
      "us-east"  = "r014-eca5d645-df08-4e03-be5c-2fb59e48c28b"
      "us-south" = "r006-afa16ff1-1465-4421-b4e6-d2bcf1d5364e"
      "jp-tok"   = "r022-b9847123-89be-41b6-81ef-d264128f667f"
      "jp-osa"   = "r034-e5491975-802f-4068-a634-344969cf2d02"
      "au-syd"   = "r026-02428319-07f0-40b7-93c3-6d3fe80b92f2"
      "br-sao"   = "r042-808d0333-dd00-4f97-9d0b-d2a02bee2db6"
      "ca-tor"   = "r038-d5143ced-f88e-4f48-badb-8c7d7484a9f9"
    }
  }
  compute_image_region_map = {
    "hpcc-scale513-rhel79-v1" = {
      "eu-gb"    = "r018-2e96795d-42a2-448c-bb91-601aa8086c35"
      "eu-de"    = "r010-102292d9-b661-43be-b2bd-d8e82785ef30"
      "us-east"  = "r014-838b2e60-0613-4d10-aa4a-18eb90fc0c6a"
      "us-south" = "r006-1fc7e0c5-d971-462b-bf03-7fa2d3475591"
      "jp-tok"   = "r022-c7dfb26f-84b3-43e1-a374-34aa6793c20e"
      "jp-osa"   = "r034-911c571e-43d4-4959-81b6-1a7a66168190"
      "au-syd"   = "r026-626140a5-bf94-4eb0-99b7-2799aeccc764"
      "br-sao"   = "r042-75150a1a-bb38-428c-8e8b-2fb365d50937"
      "ca-tor"   = "r038-10caef95-d5c4-4703-9bea-332a756595f8"
    }
    "hpcc-scale513-rhel84-v1" = {
      "eu-gb"    = "r018-469a4f1c-374e-40ab-9c66-a91feed47d32"
      "eu-de"    = "r010-66820a64-a1ea-4e72-b396-62b98fd0c237"
      "us-east"  = "r014-665cb60e-9a9d-4017-aa53-45329fffeb35"
      "us-south" = "r006-63fcce59-686c-4568-9377-3cac498ec9f1"
      "jp-tok"   = "r022-6553478a-e425-4729-8553-03e468a1a631"
      "jp-osa"   = "r034-485200f7-39d7-44bf-852c-6b6c61f0c4f6"
      "au-syd"   = "r026-9cfeccec-b2bc-4752-ac64-f99148b2330d"
      "br-sao"   = "r042-4baa49b5-bd9d-4713-bcc8-59ee05f6796f"
      "ca-tor"   = "r038-630b1eda-506c-4649-a9b3-deaff59ec25e"
    }
  }
  storage_image_region_map = {
    "hpcc-scale513-rhel84-v1" = {
      "eu-gb"    = "r018-469a4f1c-374e-40ab-9c66-a91feed47d32"
      "eu-de"    = "r010-66820a64-a1ea-4e72-b396-62b98fd0c237"
      "us-east"  = "r014-665cb60e-9a9d-4017-aa53-45329fffeb35"
      "us-south" = "r006-63fcce59-686c-4568-9377-3cac498ec9f1"
      "jp-tok"   = "r022-6553478a-e425-4729-8553-03e468a1a631"
      "jp-osa"   = "r034-485200f7-39d7-44bf-852c-6b6c61f0c4f6"
      "au-syd"   = "r026-9cfeccec-b2bc-4752-ac64-f99148b2330d"
      "br-sao"   = "r042-4baa49b5-bd9d-4713-bcc8-59ee05f6796f"
      "ca-tor"   = "r038-630b1eda-506c-4649-a9b3-deaff59ec25e"
    }
  }
}