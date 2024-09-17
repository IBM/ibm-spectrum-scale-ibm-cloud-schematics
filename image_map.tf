locals {
  bootstrap_image_region_map = {
    "hpcc-scale-bootstrap-v2-4-0" = {
      "au-syd"   = "r026-6e15086f-1200-45bb-9cb1-9eccdb44e414"
      "br-sao"   = "r042-7461ce81-b92c-45d8-96f2-091815a5236e"
      "ca-tor"   = "r038-8a670866-de36-490c-8e8b-6dd06eb066d8"
      "eu-de"    = "r010-b42feb85-590d-4cb9-9d21-deec7d263912"
      "eu-es"    = "r050-f4c1c5c9-401a-4837-b72e-cf79e3a5c1b5"
      "eu-gb"    = "r018-c7ff8491-bf0e-420f-aa30-f3c84788fd48"
      "jp-osa"   = "r034-faf41067-117e-4b42-86a1-7cc106daa370"
      "jp-tok"   = "r022-6cc764f6-9b0c-43b0-98aa-6790c08e898e"
      "us-east"  = "r014-db91517c-efe7-4260-ba49-c2be40247889"
      "us-south" = "r006-4a67d3a6-f853-4f23-9ae9-6df9c6f1090d"
    }
  }
  compute_image_region_map = {
    "hpcc-scale5201-rhel88" = {
      "au-syd"   = "r026-1b434bb0-22ca-4d22-8ab8-5f894e742b03"
      "br-sao"   = "r042-d60bf44d-544c-406b-9eb7-e8aaa74f11cf"
      "ca-tor"   = "r038-91f4e2f0-cef5-4e9c-b321-4450f57ec1e3"
      "eu-de"    = "r010-50ca7e47-2a99-45c5-a8c0-e87df64e55c3"
      "eu-es"    = "r050-1068a31b-66e9-45af-b689-812c63a32ff9"
      "eu-gb"    = "r018-cb74b034-7570-47ce-9056-a8a50b1f9c09"
      "jp-osa"   = "r034-a10f08b9-b82c-470d-8e8c-5cc8abd048d5"
      "jp-tok"   = "r022-a23c1c17-1f75-4407-98ad-7b55471f5325"
      "us-east"  = "r014-3bdeef85-499e-479a-bbf5-60f0549a6003"
      "us-south" = "r006-5bdaae02-1392-4374-8eea-96f964c00adb"
    }
  }
  storage_image_region_map = {
    "hpcc-scale5201-rhel88" = {
      "au-syd"   = "r026-1b434bb0-22ca-4d22-8ab8-5f894e742b03"
      "br-sao"   = "r042-d60bf44d-544c-406b-9eb7-e8aaa74f11cf"
      "ca-tor"   = "r038-91f4e2f0-cef5-4e9c-b321-4450f57ec1e3"
      "eu-de"    = "r010-50ca7e47-2a99-45c5-a8c0-e87df64e55c3"
      "eu-es"    = "r050-1068a31b-66e9-45af-b689-812c63a32ff9"
      "eu-gb"    = "r018-cb74b034-7570-47ce-9056-a8a50b1f9c09"
      "jp-osa"   = "r034-a10f08b9-b82c-470d-8e8c-5cc8abd048d5"
      "jp-tok"   = "r022-a23c1c17-1f75-4407-98ad-7b55471f5325"
      "us-east"  = "r014-3bdeef85-499e-479a-bbf5-60f0549a6003"
      "us-south" = "r006-5bdaae02-1392-4374-8eea-96f964c00adb"
    }
  }
  evaluation_image_region_map = {
    "hpcc-scale5201-dev-rhel88" = {
      "au-syd"   = "r026-5647b9d9-d3e3-4ca2-96b1-263ecb80f392"
      "br-sao"   = "r042-4a2564d2-6c23-4086-a0c8-b5196ebcc7f7"
      "ca-tor"   = "r038-1e187788-0158-4434-b706-5bd64f59f3c2"
      "eu-de"    = "r010-beb7a81a-7955-4f42-bc1c-0b7c4783a6dc"
      "eu-es"    = "r050-00180e17-74d7-4b56-b021-ed64fe52e456"
      "eu-gb"    = "r018-852ca1d1-b270-4278-91e9-7fe7f2b764b8"
      "jp-osa"   = "r034-62428493-317d-42b0-aeb7-fcc55576110d"
      "jp-tok"   = "r022-c4cb25b6-6847-422f-a7c5-a6abf09ffd0d"
      "us-east"  = "r014-1c1c3fbd-944a-4449-9e61-d352cf3170bd"
      "us-south" = "r006-c64a32e4-4b4d-4422-b172-07fa42c304d2"
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