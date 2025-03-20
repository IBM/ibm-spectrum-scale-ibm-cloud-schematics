locals {
  bootstrap_image_region_map = {
    "hpcc-scale-bootstrap-v2-7-0" = {
      "eu-gb"    = "r018-18cc6290-6ba7-43cc-95e2-4c21421041f2"
      "eu-es"    = "r050-3f955af9-895f-48e9-9f5d-cf939022819c"
      "eu-de"    = "r010-829e77a8-19b8-420b-a8a0-df3794fb9b1a"
      "us-east"  = "r014-2c20e9db-02b0-47dc-8966-620471a96706"
      "us-south" = "r006-bfcc283d-13d5-43e4-abe6-08e40858785c"
      "jp-tok"   = "r022-082ad266-a979-4f2f-a512-8f01c23493ad"
      "jp-osa"   = "r034-ed0bba34-8d30-4b25-922f-9556898d1cf7"
      "au-syd"   = "r026-a557a379-b956-4aa6-8f02-de6eae32f336"
      "br-sao"   = "r042-e38db793-6110-471b-a2ae-6d829a8c3f28"
      "ca-tor"   = "r038-8c2e8264-20d6-40e6-8cf4-917a747b0078"
    }
  }
  compute_image_region_map = {
    "hpcc-scale5221-rhel810" = {
      "eu-es"    = "r050-561fb6d2-e4d0-42a2-b2d8-17df8ccb9e9c"
      "eu-gb"    = "r018-5d89efa5-d53f-4deb-a3b3-d3b9bd2cd312"
      "eu-de"    = "r010-e2debf2e-a80f-40f8-903f-9a648d602faa"
      "us-east"  = "r014-c5a059c3-4fe2-4e20-8a60-86fa33d42bb0"
      "us-south" = "r006-60bc1e23-86b4-46c2-9220-5f937abd60a2"
      "jp-tok"   = "r022-7500c788-e3d1-4ebc-8dc9-b5ac12ba7b84"
      "jp-osa"   = "r034-682a378c-6b73-4bc8-ad23-6c9d2900b0b1"
      "au-syd"   = "r026-e6ace789-74bc-4ae2-a881-6236994a1018"
      "br-sao"   = "r042-54221b98-18e0-457d-83bc-142e47499d9a"
      "ca-tor"   = "r038-39520078-e7f0-4405-b70c-bca6ae91885c"
    }
  }
  storage_image_region_map = {
    "hpcc-scale5221-rhel810" = {
      "eu-es"    = "r050-561fb6d2-e4d0-42a2-b2d8-17df8ccb9e9c"
      "eu-gb"    = "r018-5d89efa5-d53f-4deb-a3b3-d3b9bd2cd312"
      "eu-de"    = "r010-e2debf2e-a80f-40f8-903f-9a648d602faa"
      "us-east"  = "r014-c5a059c3-4fe2-4e20-8a60-86fa33d42bb0"
      "us-south" = "r006-60bc1e23-86b4-46c2-9220-5f937abd60a2"
      "jp-tok"   = "r022-7500c788-e3d1-4ebc-8dc9-b5ac12ba7b84"
      "jp-osa"   = "r034-682a378c-6b73-4bc8-ad23-6c9d2900b0b1"
      "au-syd"   = "r026-e6ace789-74bc-4ae2-a881-6236994a1018"
      "br-sao"   = "r042-54221b98-18e0-457d-83bc-142e47499d9a"
      "ca-tor"   = "r038-39520078-e7f0-4405-b70c-bca6ae91885c"
    }
  }
  evaluation_image_region_map = {
    "hpcc-scale5221-dev-rhel810" = {
      "eu-gb"   = "r018-834f33dd-cdc6-4ecd-bc60-cff6fcd7ed39"
      "eu-es"   = "r050-e1707150-a7e5-49b1-9219-f57a1ff43225"
      "eu-de"   = "r010-4706ef2c-7990-4e0c-94ed-95a94646870b"
      "us-east" = "r014-96d55b8f-42c6-475b-b2ba-79b27ebc1f9a"
      "us-south" = "r006-e2eec426-4c24-4112-894c-86f20c69cf8a"
      "jp-tok"  = "r022-f78a5574-bdad-4047-bd94-f1c76d11fad5"
      "jp-osa"  = "r034-df2b53b2-46f1-4997-8329-d54c6a5e34b9"
      "au-syd"  = "r026-33a2ec6e-09cd-4186-b221-64a3e7fc3e72"
      "br-sao"  = "r042-32d2e64a-70a3-4101-833e-868f7c92b37a"
      "ca-tor"  = "r038-229a14cf-3bb2-4afa-bcb2-4be7e2394a17"
    }
  }
  scale_encryption_image_region_map = {
    "hpcc-scale-gklm4202-v2-5-2" = {
      "eu-es"   = "r050-e544235d-8dba-4224-b226-ffc454fc0719"
      "eu-gb"   = "r018-298c7a17-e948-4bf2-9ebd-1e75daad5788"
      "eu-de"   = "r010-525c9fa7-e0b5-4052-b1bd-1ccf6fd1dd05"
      "us-east" = "r014-37f51029-1fe4-4be4-9cb4-eaea4fea04b0"
      "us-south" = "r006-018249db-dc3e-41f9-b8c3-54acc9d31fe3"
      "jp-tok"  = "r022-fca2c7f3-09c3-4492-bcf7-9942842f9821"
      "jp-osa"  = "r034-f5142d13-ef5d-48d5-bf63-656b6ea65cf3"
      "au-syd"  = "r026-307a9fc7-c3c6-4989-b673-767f31a0a9ee"
      "br-sao"  = "r042-e0bc8312-b107-4449-bc7e-22e43faa08e4"
      "ca-tor"  = "r038-9eed52d7-30e2-40d9-9bdf-a2806f162307"
    }
  }
}