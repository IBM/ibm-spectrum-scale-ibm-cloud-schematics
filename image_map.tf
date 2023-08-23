locals {
  bootstrap_image_region_map = {
    "hpcc-scale-bootstrap-v2-1-2" = {
      "eu-gb"    = "r018-83a85898-15ca-4129-82e0-9a13008d01f9"
      "eu-de"    = "r010-02af73d9-3989-4229-8a0e-4d9e61eac6f3"
      "us-east"  = "r014-28faf89f-cb83-46e5-9d87-2c918f1d81ec"
      "us-south" = "r006-fd05e935-dccc-44ae-b558-09fbe8aee3bb"
      "jp-tok"   = "r022-2acd24db-cc84-447b-863b-8c8f1cf6d0af"
      "jp-osa"   = "r034-db75c7a0-5020-464d-ae0c-8b2b79468f1a"
      "au-syd"   = "r026-8372919b-7390-4b3a-8d4e-8c3c7191d810"
      "br-sao"   = "r042-edc5ed2f-6d23-4002-80a7-3fe66fbcf138"
      "ca-tor"   = "r038-eeafd098-fff3-4b2f-a732-2f09c18e8f33"
    }
  }
  compute_image_region_map = {
    "hpcc-scale5181-rhel79" = {
      "eu-gb"    = "r018-262dff8d-6940-4f6a-ad0b-0cd05d33e4bb"
      "eu-de"    = "r010-963fcdbc-a82b-46ac-92d3-86da5874a952"
      "us-east"  = "r014-27de379b-f972-4340-aa39-c1df18d91e21"
      "us-south" = "r006-532d0557-bfa7-4285-a632-09e5eca6d471"
      "jp-tok"   = "r022-0b129b17-38fc-4b1c-8a07-268d9a2f1147"
      "jp-osa"   = "r034-6710b3ff-46df-4baf-b999-2a9ee92b3012"
      "au-syd"   = "r026-e00278c9-da23-44c7-bc51-3ccbd7f30409"
      "br-sao"   = "r042-11740f1e-b4b3-4b80-b40e-073dab9ab638"
      "ca-tor"   = "r038-389fc283-3521-4cd3-9cb1-e423098ef4f5"
    }
    "hpcc-scale5181-rhel86" = {
      "eu-gb"    = "r018-3c56e12b-ec68-41db-a638-287d408340a5"
      "eu-de"    = "r010-49920a12-9624-481d-83cf-8dcf0ab95ded"
      "us-east"  = "r014-05439186-c33f-4afb-91cd-a1f41d324ca3"
      "us-south" = "r006-29a3e468-518e-4e80-8b63-15d6967ac0a0"
      "jp-tok"   = "r022-19c51af1-49eb-4d3a-b4ba-de3d97486d8b"
      "jp-osa"   = "r034-8132f843-0bbe-4535-8a7e-d46e496f3343"
      "au-syd"   = "r026-cd06cb5f-2dfc-4ffc-9fb8-325d4da392b2"
      "br-sao"   = "r042-f119f17e-1ca6-4a88-8da2-df92f22b5970"
      "ca-tor"   = "r038-32120d65-3ad5-4d81-ac81-12063356ded7"
    }
  }
  storage_image_region_map = {
    "hpcc-scale5181-rhel86" = {
      "eu-gb"    = "r018-3c56e12b-ec68-41db-a638-287d408340a5"
      "eu-de"    = "r010-49920a12-9624-481d-83cf-8dcf0ab95ded"
      "us-east"  = "r014-05439186-c33f-4afb-91cd-a1f41d324ca3"
      "us-south" = "r006-29a3e468-518e-4e80-8b63-15d6967ac0a0"
      "jp-tok"   = "r022-19c51af1-49eb-4d3a-b4ba-de3d97486d8b"
      "jp-osa"   = "r034-8132f843-0bbe-4535-8a7e-d46e496f3343"
      "au-syd"   = "r026-cd06cb5f-2dfc-4ffc-9fb8-325d4da392b2"
      "br-sao"   = "r042-f119f17e-1ca6-4a88-8da2-df92f22b5970"
      "ca-tor"   = "r038-32120d65-3ad5-4d81-ac81-12063356ded7"
    }
  }
  evaluation_image_region_map = {
    "hpcc-scale518-rhel86" = {
      "eu-gb"    = "r018-5f478b5e-d144-47f3-bf5e-ba45bab6e619"
      "eu-de"    = "r010-a286b8c7-036d-4841-bf1f-ec4de5f94524"
      "us-east"  = "r014-266a71e4-b8f1-416e-bcf9-afd4f935bb36"
      "us-south" = "r006-052fdcc8-784c-4e5d-9059-d4f55a024b85"
      "jp-tok"   = "r022-2cf4aea3-76b2-443c-9449-945bc1e4f8d3"
      "jp-osa"   = "r034-4d6a3173-d7b1-4037-aa53-1298ea0d7134"
      "au-syd"   = "r026-054d5f32-45b0-4733-8923-ae445c132d01"
      "br-sao"   = "r042-5438da99-8af4-412f-98f2-480cda24e9ff"
      "ca-tor"   = "r038-7acab6b9-39b4-4722-a9a0-ca8471830b27"
    }
  }
}
