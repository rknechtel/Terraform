## inputs\prd.auto.tfvars

location="centralus"
locshort="cus"
service="apim"
baseindex="0001"
baseprefix="az"
subnetprefix="112.15.111.0/24"
apimsku="Premium_1"
servicedomain="prodapache"
userassignedidentity="prspImportRootCA"
aadten="af3b07d3-11b5-4660-8702-4db77bdf01beeeeee"
aadid="ee8d1697-9a8d-440e-b1b5-a50a494f985eeeeeee"
prdoverride="az-p-network-p-rg-p-cus-00011111111"
### Custom Domain Name ###
customdomain="ENV-apim.MYDOMAIN.com"
keyvaultsecretid="https://az-p-apimkeyvault.vault.azure.net/secrets/ENV-apim-MYDOMAIN-com/e70a1e08f30346d56c2bc6f7bbfea8e3"
cacertpfxpw = "MYCERTPASSWORD"
