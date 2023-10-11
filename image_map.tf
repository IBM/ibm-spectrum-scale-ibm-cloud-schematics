locals {
  bootstrap_image_region_map = {
    "hpcc-scale-bootstrap-v2-2" = {
      "eu-gb"    = "r018-d393986d-15b7-4bb9-bc10-6c9e7d0d4ec5"
      "eu-de"    = "r010-e885c48a-0c2f-40a6-9d08-378502cc1e3a"
      "us-east"  = "r014-20211080-34be-458a-99bc-29e024a1ff08"
      "us-south" = "r006-e27031d0-2145-476f-a3a2-c3825ed524c9"
      "jp-tok"   = "r022-4f0c4759-4d90-4897-86b4-a390dc567987"
      "jp-osa"   = "r034-f7eb81c1-5043-47c9-8ee9-9d8ea59c6b33"
      "au-syd"   = "r026-2275cf26-4734-4797-bbb1-2f213aa157f4"
      "br-sao"   = "r042-5604fdbe-386e-48ad-8a0e-a21805e0b82e"
      "ca-tor"   = "r038-2435aaa9-b4d6-4f38-9e9d-7c621bc7198f"
    }
  }
  compute_image_region_map = {
    "hpcc-scale5181-rhel79" = {
      "eu-gb"    = "r018-2c72db65-27c9-45d0-ac63-ee2fcf3271eb"
      "eu-de"    = "r010-f9899667-6524-49d0-aa10-c84e8f03283e"
      "us-east"  = "r014-1ffebbc8-f8b0-4543-a421-40a3687e36e1"
      "us-south" = "r006-70b638ca-8509-4114-9a8a-b16202356ad9"
      "jp-tok"   = "r022-32bad7c3-09eb-4277-a41b-e4318ae63a74"
      "jp-osa"   = "r034-f70b36a8-637b-4ace-8817-18773c67a158"
      "au-syd"   = "r026-4d2f0d7a-9f5a-41f1-81b2-4ecd2bff38a9"
      "br-sao"   = "r042-64b91672-d03b-4c1b-a364-951e3e67df3d"
      "ca-tor"   = "r038-7e430dc4-8bba-4263-9d30-ef44a4ff942d"
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
  scale_encryption_image_region_map = {
    "hpcc-scale-gklm-v4-1-1-7" = {
      "eu-gb"    = "r018-0344b93b-fca0-42dc-b30f-8ef8bfaed669"
      "eu-de"    = "r010-5281b2a5-9c94-4461-a2b6-00f4d5e5b326"
      "us-east"  = "r014-47643060-b1c0-470a-be3e-19e25c9c9e7a"
      "us-south" = "r006-5bd61c86-f254-47ee-b715-4cd3361a3a66"
      "jp-tok"   = "r022-ed732b0b-cd54-42c5-bb08-bb1bd53464e4"
      "jp-osa"   = "r034-7faf0c47-0dff-4e2a-a5f5-c0b34742af31"
      "au-syd"   = "r026-1d7b62d6-1482-4b83-a3d6-981d78a93eec"
      "br-sao"   = "r042-b881fe6c-a136-4292-aba9-78cc0b6ec0d9"
      "ca-tor"   = "r038-78eb3b33-77de-43ce-89a7-0222c16c07cf"
    }
  }
}