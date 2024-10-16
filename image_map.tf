locals {
  bootstrap_image_region_map = {
    "hpcc-scale-bootstrap-v2-6-0" = {
      "au-syd"   = "r026-93586663-e82a-42cf-a8e7-6ab58d4a584c"
      "br-sao"   = "r042-a76731f3-0964-49bf-a387-69c6cb229d0e"
      "ca-tor"   = "r038-47862814-ac58-4217-b73c-0626e1cfd426"
      "eu-de"    = "r010-fddd5af0-de87-4ec1-96f7-84b532ba1db6"
      "eu-es"    = "r050-3f3c2182-557f-49ae-b285-8eccdc0d230f"
      "eu-gb"    = "r018-203d3aba-df32-41f7-892b-517ca3a6a89f"
      "jp-osa"   = "r034-c80c8368-6697-49e3-82cc-c736d5832383"
      "jp-tok"   = "r022-03b549da-0a7c-403f-9270-c0f223582f0b"
      "us-east"  = "r014-38c429e1-476d-4e85-ac11-d93e14615863"
      "us-south" = "r006-a6fac2dd-1c73-4b93-ab17-39e5fc3f1d5b"
    }
  }
  compute_image_region_map = {
    "hpcc-scale5211-rhel810" = {
      "au-syd"   = "r026-e8ed81b4-d974-47cd-98b2-8ab122f9f793"
      "br-sao"   = "r042-83ef5052-2f41-4f01-90d5-d542af676bc3"
      "ca-tor"   = "r038-c89c5867-fa4f-4fa4-b773-e030f11249bb"
      "eu-de"    = "r010-5c7331b2-2b0c-4eef-925c-31a93a8dbbdc"
      "eu-es"    = "r050-713ffa8f-5b1e-4c45-838c-b271aa04df97"
      "eu-gb"    = "r018-5bbd380f-1326-4a79-b992-fb0e06417a95"
      "jp-osa"   = "r034-5dd849c9-86e2-4513-801c-b96ef0f4b3d2"
      "jp-tok"   = "r022-e4aab701-36a1-4f8b-8641-55d626378d9a"
      "us-east"  = "r014-929bfaad-2b80-4acf-bc3f-4a2a01f8cc57"
      "us-south" = "r006-c24af608-ae93-41d3-8c27-bad8aa93ac9d"
    }
  }
  storage_image_region_map = {
    "hpcc-scale5211-rhel810" = {
      "au-syd"   = "r026-e8ed81b4-d974-47cd-98b2-8ab122f9f793"
      "br-sao"   = "r042-83ef5052-2f41-4f01-90d5-d542af676bc3"
      "ca-tor"   = "r038-c89c5867-fa4f-4fa4-b773-e030f11249bb"
      "eu-de"    = "r010-5c7331b2-2b0c-4eef-925c-31a93a8dbbdc"
      "eu-es"    = "r050-713ffa8f-5b1e-4c45-838c-b271aa04df97"
      "eu-gb"    = "r018-5bbd380f-1326-4a79-b992-fb0e06417a95"
      "jp-osa"   = "r034-5dd849c9-86e2-4513-801c-b96ef0f4b3d2"
      "jp-tok"   = "r022-e4aab701-36a1-4f8b-8641-55d626378d9a"
      "us-east"  = "r014-929bfaad-2b80-4acf-bc3f-4a2a01f8cc57"
      "us-south" = "r006-c24af608-ae93-41d3-8c27-bad8aa93ac9d"
    }
  }
  evaluation_image_region_map = {
    "hpcc-scale5210-dev-rhel810" = {
      "au-syd"   = "r026-293e8809-5394-40c6-8cb5-6f4ad24d8d00"
      "br-sao"   = "r042-2106d50c-d72a-4c28-84d0-8d8dacff8513"
      "ca-tor"   = "r038-33c0abfe-d2ae-4355-9bca-dd9f72b00040"
      "eu-de"    = "r010-85ed4005-fadb-4d9c-80be-95c682e27847"
      "eu-es"    = "r050-fbf55531-d19b-49fb-83f0-88acaee4751d"
      "eu-gb"    = "r018-f2ed31b1-c69a-4449-a334-6a54764286e3"
      "jp-osa"   = "r034-40de294a-5c79-4a71-aedf-a0b8a91ba8d7"
      "jp-tok"   = "r022-0648560d-b004-402a-b88a-d0d54592e9a3"
      "us-east"  = "r014-346d7cd9-276a-4fb2-9ad8-5c36ebeaaa13"
      "us-south" = "r006-beb452bc-465d-4e69-bced-28802fabe539"
    }
  }
  scale_encryption_image_region_map = {
    "hpcc-scale-gklm4202-v2-5-1" = {
      "au-syd"   = "r026-d6ed646c-81a3-4043-8c21-0940ea96c714"
      "br-sao"   = "r042-4798da9d-4757-44ae-999b-2447849969dc"
      "ca-tor"   = "r038-326ce738-b4a9-4dca-8970-0713aab6b9b3"
      "eu-de"    = "r010-850c94ca-33da-4a23-bb75-a99c49dc2b6b"
      "eu-es"    = "r050-a2b1b2bf-451e-4316-bbe5-0bc1d85d2fb0"
      "eu-gb"    = "r018-3cd3412a-7687-42bc-b7e7-6282951f9f4d"
      "jp-osa"   = "r034-fc9dfdda-a30c-4da0-82cf-88543f57197b"
      "jp-tok"   = "r022-e17d85cc-3dc3-4c6e-a4e3-c837ee149949"
      "us-east"  = "r014-5dd26aab-83c9-431b-97d5-5ae764abbdcc"
      "us-south" = "r006-cab9d86b-7316-4e2b-9cdc-4d3c0ce3b735"
    }
  }
}