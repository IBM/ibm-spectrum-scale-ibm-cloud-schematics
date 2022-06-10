locals {
  bootstrap_image_region_map = {
    "hpcc-scale-bootstrap-v1" = {
      "eu-gb"    = "r018-b4fdd69b-4cf4-4b2b-8105-1bf3ae99ecd2"
      "eu-de"    = "r010-2522509b-0f54-45ff-bdc4-ecc82895664e"
      "us-east"  = "r014-1fc59bbc-3690-4018-b8b1-6d94dd7ef6d3"
      "us-south" = "r006-9db83c89-52a8-4236-921a-46ec04fce6a2"
      "jp-tok"   = "r022-c0affa5d-972e-4559-9a68-11c91a06ecf0"
      "jp-osa"   = "r034-9c8c0405-59a1-41cf-a347-4423362a6e1e"
      "au-syd"   = "r026-63974eda-6295-46dc-9ba9-58c6064ccc54"
      "br-sao"   = "r042-dfa4bf16-87ca-4340-94ac-0de4b4a1f579"
      "ca-tor"   = "r038-55f61a27-ab27-4ab4-a9da-c343b8af0f36"
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