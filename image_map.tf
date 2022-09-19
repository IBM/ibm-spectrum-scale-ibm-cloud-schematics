locals {
  bootstrap_image_region_map = {
    "hpcc-scale-bootstrap-v2" = {
      "eu-gb"    = "r018-7500e6a6-d005-4c1b-bb80-e8c4f992b61d"
      "eu-de"    = "r010-88eb3deb-1c31-4c53-82f5-a1ffab476858"
      "us-east"  = "r014-33c3346d-adfb-46ef-9c0e-7663087047c9"
      "us-south" = "r006-65e0873b-4e4b-419c-ae92-2f86196ce7a7"
      "jp-tok"   = "r022-80c60ced-1199-481b-8265-39f59f76208d"
      "jp-osa"   = "r034-5304535f-502b-4012-adf3-62551c2ec6f8"
      "au-syd"   = "r026-a7a1eb4f-a905-4f7c-a17e-8bf5d7329728"
      "br-sao"   = "r042-5aa29b6a-deec-4d89-8aaf-8f51df38fd97"
      "ca-tor"   = "r038-ec5b7d1d-06c1-48cc-85e2-8f206a9e072a"
    }
  }
  compute_image_region_map = {
    "hpcc-scale5141-rhel79-v2" = {
      "eu-gb"    = "r018-e534b5da-9df9-4f9e-81ac-7767439a91bc"
      "eu-de"    = "r010-02c45f4c-e6c5-4b69-89a2-ea87a6a459b8"
      "us-east"  = "r014-8fa1a91e-1759-4b26-9e3e-e9ad843c309c"
      "us-south" = "r006-58725771-680d-4b11-8b4b-b1fd2877db9c"
      "jp-tok"   = "r022-b4322da3-7ace-415f-941f-d888aff5d0c8"
      "jp-osa"   = "r034-3bc215aa-8f0c-41d0-8b8e-7b27e5c48ba4"
      "au-syd"   = "r026-3131d7b3-6dd0-4101-892c-92059b3ac6f8"
      "br-sao"   = "r042-8eee44a2-efb6-4554-8d1f-a07042681e81"
      "ca-tor"   = "r038-af56d7ed-c769-4c18-a1aa-eb1a53868db2"
    }
    "hpcc-scale5141-rhel84-v2" = {
      "eu-gb"    = "r018-73da8cbf-3b86-4fec-b699-a20768cd3aa5"
      "eu-de"    = "r010-91d7dec9-4fb7-4c8d-87b9-431fa3847933"
      "us-east"  = "r014-2288182d-4018-4931-8f7d-dac09e07e9c7"
      "us-south" = "r006-661cace6-6ec5-48fc-89dd-c13fee7b638e"
      "jp-tok"   = "r022-a3b89aff-3055-4867-8526-b333ffdd8cae"
      "jp-osa"   = "r034-49f18af8-e429-471a-b816-36cd4af5a898"
      "au-syd"   = "r026-20d1de77-b4ae-4257-bea3-bf02ef12f6f7"
      "br-sao"   = "r042-c1462fa1-cacc-4c70-ae03-0fbb4e509a1f"
      "ca-tor"   = "r038-37849378-aae1-408f-ac58-0ecf378099ca"
    }
  }
  storage_image_region_map = {
    "hpcc-scale5141-rhel84-v2" = {
      "eu-gb"    = "r018-73da8cbf-3b86-4fec-b699-a20768cd3aa5"
      "eu-de"    = "r010-91d7dec9-4fb7-4c8d-87b9-431fa3847933"
      "us-east"  = "r014-2288182d-4018-4931-8f7d-dac09e07e9c7"
      "us-south" = "r006-661cace6-6ec5-48fc-89dd-c13fee7b638e"
      "jp-tok"   = "r022-a3b89aff-3055-4867-8526-b333ffdd8cae"
      "jp-osa"   = "r034-49f18af8-e429-471a-b816-36cd4af5a898"
      "au-syd"   = "r026-20d1de77-b4ae-4257-bea3-bf02ef12f6f7"
      "br-sao"   = "r042-c1462fa1-cacc-4c70-ae03-0fbb4e509a1f"
      "ca-tor"   = "r038-37849378-aae1-408f-ac58-0ecf378099ca"
    }
  }
}