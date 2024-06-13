locals {
  bootstrap_image_region_map = {
    "hpcc-scale-bootstrap-v2-4" = {
      "eu-gb"    = "r018-f77a2609-b31e-45e2-be70-76918ca57c0b"
      "eu-de"    = "r010-44b8fe7b-531e-4647-9507-575f0552c23b"
      "us-east"  = "r014-acac9de1-3d52-4348-8a0c-160b9f8a354a"
      "us-south" = "r006-22a9d947-5c17-4ba8-b710-01b7d054d098"
      "jp-tok"   = "r022-eaa1389b-03c5-4391-b7a8-d44d8367e969"
      "jp-osa"   = "r034-958b15ab-bbd3-4029-adf7-b868d348a418"
      "au-syd"   = "r026-6534096f-47ff-4508-9352-e2fd3d0f95f6"
      "br-sao"   = "r042-91dcbeb1-eb22-43a9-a934-ba44dce6f2e1"
      "ca-tor"   = "r038-2eaf396b-4fae-4128-aa3b-26625d202058"
    }
  }
  compute_image_region_map = {
    "hpcc-scale5192-rhel79" = {
      "eu-gb"    = "r018-7b640048-9b8d-42a5-98c3-8028265d8f94"
      "eu-de"    = "r010-a2d513b2-5980-4847-9065-290c378a73ce"
      "us-east"  = "r014-a94769a6-d484-4c9f-9ae8-d838c384f86b"
      "us-south" = "r006-f6f37a28-9b71-4ea0-b27b-8a86085936cc"
      "jp-tok"   = "r022-a6d1915e-8019-444c-9238-0750a8d77d62"
      "jp-osa"   = "r034-4073eb17-e346-4400-8043-bd3159976509"
      "au-syd"   = "r026-17b0582b-c36c-4ea7-85cf-793820b83e62"
      "br-sao"   = "r042-0b43b560-26d7-4f4d-9e7e-609bd30edbc3"
      "ca-tor"   = "r038-83d1c260-4493-4276-a5cd-154fb2b076b4"
    }
    "hpcc-scale5192-rhel88" = {
      "eu-gb"    = "r018-59282786-062d-4bdc-94b5-286afb955942"
      "eu-de"    = "r010-430fd27f-cd6c-4abf-9a23-fe0cdcea65ef"
      "us-east"  = "r014-caff33a9-6af7-45f9-8b51-2f25c403a855"
      "us-south" = "r006-3f18de9b-f836-45c0-b7b4-2ad39e61bda4"
      "jp-tok"   = "r022-4a1aafa1-0ae8-4d5e-8250-42ae9042bfe5"
      "jp-osa"   = "r034-9427cd75-fa6d-41ce-9441-b2bc3f37f7f8"
      "au-syd"   = "r026-ef3ed548-b20a-4d05-9380-1efbde99bb24"
      "br-sao"   = "r042-be9f52f5-02d7-44a5-a468-c861de010516"
      "ca-tor"   = "r038-63f00416-8dac-4fcf-b311-8b8d5a66eeb9"
    }
  }
  storage_image_region_map = {
    "hpcc-scale5192-rhel88" = {
      "eu-gb"    = "r018-59282786-062d-4bdc-94b5-286afb955942"
      "eu-de"    = "r010-430fd27f-cd6c-4abf-9a23-fe0cdcea65ef"
      "us-east"  = "r014-caff33a9-6af7-45f9-8b51-2f25c403a855"
      "us-south" = "r006-3f18de9b-f836-45c0-b7b4-2ad39e61bda4"
      "jp-tok"   = "r022-4a1aafa1-0ae8-4d5e-8250-42ae9042bfe5"
      "jp-osa"   = "r034-9427cd75-fa6d-41ce-9441-b2bc3f37f7f8"
      "au-syd"   = "r026-ef3ed548-b20a-4d05-9380-1efbde99bb24"
      "br-sao"   = "r042-be9f52f5-02d7-44a5-a468-c861de010516"
      "ca-tor"   = "r038-63f00416-8dac-4fcf-b311-8b8d5a66eeb9"
    }
  }
  evaluation_image_region_map = {
    "hpcc-scale5192-rhel88" = {
      "eu-gb"    = "r018-59282786-062d-4bdc-94b5-286afb955942"
      "eu-de"    = "r010-430fd27f-cd6c-4abf-9a23-fe0cdcea65ef"
      "us-east"  = "r014-caff33a9-6af7-45f9-8b51-2f25c403a855"
      "us-south" = "r006-3f18de9b-f836-45c0-b7b4-2ad39e61bda4"
      "jp-tok"   = "r022-4a1aafa1-0ae8-4d5e-8250-42ae9042bfe5"
      "jp-osa"   = "r034-9427cd75-fa6d-41ce-9441-b2bc3f37f7f8"
      "au-syd"   = "r026-ef3ed548-b20a-4d05-9380-1efbde99bb24"
      "br-sao"   = "r042-be9f52f5-02d7-44a5-a468-c861de010516"
      "ca-tor"   = "r038-63f00416-8dac-4fcf-b311-8b8d5a66eeb9"
    }
  }
  scale_encryption_image_region_map = {
    "hpcc-scale-gklm-v4-2-0-3" = {
      "eu-gb"    = "r018-71cc46f5-8849-40f9-b335-bd2e068d222b"
      "eu-de"    = "r010-4f398413-36aa-4aea-b252-c0dd25e8b827"
      "us-east"  = "r014-3a086c9b-756d-42f0-93cf-77e1cd26f419"
      "us-south" = "r006-8d48bfde-5e02-4fd2-b9f3-fd5e4e15307b"
      "jp-osa"   = "r034-5b37c5a0-819b-47bb-86ef-6b0c7e0ccd0e"
      "br-sao"   = "r042-cfb8f4ce-5c52-4839-8259-4615cf6dd057"
      "au-syd"   = "r026-9983cadc-3210-42f0-94ec-04515e17e0b1"
      "jp-tok"   = "r022-ca328fdf-ba6b-42d0-80b6-3525614e3648"
      "ca-tor"   = "r038-61b4de0d-34d7-48ea-b6d4-6b47eb0aa6a8"
    }
  }
}