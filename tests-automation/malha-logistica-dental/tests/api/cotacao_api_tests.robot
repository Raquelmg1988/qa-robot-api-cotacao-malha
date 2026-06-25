*** Settings ***
Library           RequestsLibrary
Library           Collections
Resource          ../../keywords/shipping_keywords.robot
Resource          ../../configs/config_api_malha.robot
Suite Setup       Criar Sessao API

*** Test Cases ***

Cotacao De Frete Com Sucesso
    ${produto}=    Criar Produto    ${SKU}    1    ${PRICE}
    ${produtos}=   Create List    ${produto}
    ${body}=       Create Dictionary
    ...    deliveryZipCode=${ZIPCODE}
    ...    products=${produtos}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    
    Log To Console    Body enviado: ${body}
    ${response}=   POST On Session    malha    /shipping-quote    json=${body}    expected_status=any
    Log To Console    Status: ${response.status_code} | Resposta: ${response.text}
    Should Be Equal As Integers    ${response.status_code}    201
    
    ${json}=       Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json}    data

Cotacao Sem Estoque
    ${produto}=    Criar Produto    ${SKU_SEM_ESTOQUE}    ${QTD_SEM_ESTOQUE}    ${PRICE_SEM_ESTOQUE}
    ${produtos}=   Create List    ${produto}
    ${body}=       Create Dictionary
    ...    deliveryZipCode=${ZIPCODE}
    ...    products=${produtos}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    
    ${response}=   POST On Session    malha    /shipping-quote    json=${body}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    201
    
    ${json}=       Set Variable    ${response.json()}
    ${data}=       Get From Dictionary    ${json}    data
    Dictionary Should Contain Key    ${data}    warning

Cotacao CEP Invalido
    ${produto}=    Criar Produto    ${SKU}    10    ${PRICE}
    ${produtos}=   Create List    ${produto}
    ${body}=       Create Dictionary
    ...    deliveryZipCode=00000000
    ...    products=${produtos}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    
    ${response}=   POST On Session    malha    /shipping-quote    json=${body}    expected_status=any
    # Exige 422 conforme o Swagger para expor o erro real da API
    Should Be Equal As Integers    ${response.status_code}    422

Cotacao Sem Produtos
    ${body}=       Create Dictionary
    ...    deliveryZipCode=${ZIPCODE}
    ...    products=${EMPTY}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    
    ${response}=   POST On Session    malha    /shipping-quote    json=${body}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    422
    
    ${json}=       Set Variable    ${response.json()}
    Dictionary Should Contain Item    ${json}    code        VALIDATION
