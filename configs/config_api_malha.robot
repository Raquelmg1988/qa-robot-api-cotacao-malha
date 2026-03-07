*** Variables ***
${BASE_URL}             https://api-hml-malha.suryadental.com.br
${API_KEY}              mds_YPxIB9J2a18SCxZ1jR-hWlO8LGmOluJPsVGWsgIea1I

&{HEADERS}              Content-Type=application/json
...                     x-api-key=${API_KEY}

${ZIPCODE}              85340000
${SKU}                  100306000
${PRICE}                11.86

${SKU2}                 100306001
${PRICE2}               15.00

${SALES_ID}             A00018
${SURYA_CLUB_CODE}      20

${SKU_SEM_ESTOQUE}      100306000
${QTD_SEM_ESTOQUE}      999999
${PRICE_SEM_ESTOQUE}    11.86

${DISTRIBUTION_DOC}     00814559000155

${ENDPOINT_SHIPPING_QUOTE}     /shipping-quote
${ENDPOINT_RECALC}             /shipping-quote/recalc