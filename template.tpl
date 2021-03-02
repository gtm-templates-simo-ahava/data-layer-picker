___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "categories": [
    "UTILITY"
  ],
  "__wm": "VGVtcGxhdGUtQXV0aG9yX0RhdGFMYXllclBpY2tlci1TaW1vLUFoYXZh",
  "securityGroups": [],
  "displayName": "Data Layer Picker",
  "description": "Pick keys and values from the dataLayer push (and that push alone) that caused this tag to be evaluated.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "RADIO",
    "name": "option",
    "displayName": "Value to return",
    "radioItems": [
      {
        "value": "object",
        "displayValue": "Entire object"
      },
      {
        "value": "key",
        "displayValue": "Specific property",
        "subParams": [
          {
            "type": "TEXT",
            "name": "keyName",
            "displayName": "Property name",
            "simpleValueType": true
          }
        ],
        "help": ""
      }
    ],
    "simpleValueType": true,
    "help": "If you choose \"Entire object\", the whole object that was pushed into dataLayer will be returned. If you choose \"Specific property\", you can then provide the key (using dot notation if necessary) whose value you want to pull from the pushed dataLayer object."
  },
  {
    "type": "SELECT",
    "name": "mapEvent",
    "displayName": "From Specific Event?",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "no",
        "displayValue": "no"
      },
      {
        "value": 1,
        "displayValue": "Event Occurrence Number (For all events)"
      },
      {
        "value": 2,
        "displayValue": "By Especific Event and Occurrence Number"
      },
      {
        "value": 3,
        "displayValue": "By Especific Event - First Occurrence"
      },
      {
        "value": 4,
        "displayValue": "By Especific Event - Penult Occurrence"
      },
      {
        "value": 5,
        "displayValue": "By Especific Event - Last Occurrence"
      }
    ],
    "simpleValueType": true,
    "help": "No - Will get the variable value at the at the current event\u003cbr\u003e\u003cbr\u003e\n\nEvent Occurrence Number - It will take the value of the variable from the specified number of the event according to the firing order of all events\u003cbr\u003e\u003cbr\u003e\n\nBy Especific Event and Occurrence Number - It will take the variable value of the specified ccurrence number of an event specified by the name\u003cbr\u003e\u003cbr\u003e\n\nBy Especific Event - Penult Occurrence - It will take the value of the variable from the penultimate occurrence of an event specified by the name\nBy Especific Event - First Occurrence - It will take the value of the variable from the first occurrence of an event specified by the name",
    "defaultValue": "no"
  },
  {
    "type": "TEXT",
    "name": "eventName",
    "displayName": "Event Name",
    "simpleValueType": true,
    "help": "Especify the name of the event. Must be the identification of the event, not the user friendly name.\n\nE.g.: If you want to especify the click event, you must input \"gtm.click\", not \"Click\"",
    "enablingConditions": [
      {
        "paramName": "mapEvent",
        "paramValue": 2,
        "type": "EQUALS"
      },
      {
        "paramName": "mapEvent",
        "paramValue": 3,
        "type": "EQUALS"
      },
      {
        "paramName": "mapEvent",
        "paramValue": 4,
        "type": "EQUALS"
      },
      {
        "paramName": "mapEvent",
        "paramValue": 5,
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "eventIdx",
    "displayName": "Event Especific Ocurrency Number",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "mapEvent",
        "paramValue": 1,
        "type": "EQUALS"
      },
      {
        "paramName": "mapEvent",
        "paramValue": 2,
        "type": "EQUALS"
      }
    ],
    "help": "Especify the occurence number of the event. If the event \"gtm.click\" occured 3 times and you want to get the value of an variable whem the 2nd ocurrency, input 2 as the value of this filed.",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      },
      {
        "type": "POSITIVE_NUMBER"
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const copyFromDataLayer = require('copyFromDataLayer');
const copyFromWindow = require('copyFromWindow');
const JSON = require('JSON');
const log = require('logToConsole');

const gtmId = copyFromDataLayer('gtm.uniqueEventId');
const dataLayer = copyFromWindow('dataLayer');
const makeNumber = require('makeNumber');

let obj = [];

// Helper inspired by https://bit.ly/3bAAz32
// Modified by Rodrigo Passos Gregorio to ensure that props with "gtm." doens't cause in bugs
const get = (obj, path, def) => {
  path = path.split('.');

  // If first element of path equals "gtm" it means the searched key have the "." character when declared
  // Normally these are default GTM keys in dataLayer 
  if(path.length >= 2 && path[0] == 'gtm'){
    path.shift();
    path[0] = 'gtm.' + path[0];
  }
  
  let current = obj;
  
  for (let i = 0; i < path.length; i++) {
    if (!current[path[i]]) return def;
    current = current[path[i]];
  }

  return current;
};

if (dataLayer && gtmId) {
    // Get object from dataLayer that matches the gtm.uniqueEventId
    obj = dataLayer.map(o => {
      // If a regular dataLayer object, return it
      if (o['gtm.uniqueEventId']){
        return o;
      }
      // Other wise assume it's a template constructor-based object
      // Clone the object to remove constructor, then return first
      // property in the object (the wrapper).
      o = JSON.parse(JSON.stringify(o));
      for (let prop in o) {
        return o[prop];
      }
    }).filter(o => {
      // Filter to only include the item(s) where the event ID matches - No specific ocurrency or event name
      if(data.mapEvent == "no" && o['gtm.uniqueEventId'] === gtmId) return true;
      // If search must be at all dataLayer events, return all ocurrencies - Specified ocurrency only
      else if(o && o['gtm.uniqueEventId'] && data && data.mapEvent == '1') return true;
      // If search must be at specific dataLayer event, return all specific dataLayer events - Specified ocurrency and event name
      else if(o && o['gtm.uniqueEventId'] && data && data.mapEvent && data.mapEvent != '1'  && o.event == data.eventName) return true;
    });

  var dme = data.mapEvent;
  data.eventIdx = makeNumber(data.eventIdx);
  
  
  let idx = 0;
  if(!!((dme && obj.length) && ((dme == "no") || (dme == '1') || (dme == '2')) && (obj.length >= data.eventIdx))){
    idx = (data.eventIdx-1);
  } else if(dme &&  dme == '3'                 && obj.length){
    idx = 0;
  } else if(dme &&  dme == '4'                 && obj.length >=2){
    idx = obj.length-2;
  } else if(dme &&  dme == '5'                 && obj.length){
    idx = obj.length-1;
  } else if(obj.length){
    idx = obj.length - 1;
  } else {
    idx = 0;
  }
  
  obj = obj.length ? obj[idx] : {};
  
  switch (data.option) {
    case 'object':
      return obj;
    case 'key':
      return get(obj, data.keyName, obj[data.keyName]);
  }
}


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "access_globals",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "dataLayer"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "gtm"
              },
              {
                "type": 1,
                "string": "gtm.*"
              },
              {
                "type": 1,
                "string": "gtm.uniqueEventId"
              },
              {
                "type": 1,
                "string": "ecommerce"
              },
              {
                "type": 1,
                "string": "ecommerce.*"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Fetches OBJECT from regular dL array
  code: |-
    mock('copyFromDataLayer', key => {
      return 1;
    });

    mock('copyFromWindow', key => {
      return dataLayer;
    });

    // Call runCode to run the template's code.
    const variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo({'gtm.uniqueEventId': 1, event: 'Event1', firstItem: {test: 'yes'}, ecommerce: {impression:[{name: 'product_name1'}]}});
- name: Fetches KEY from regular dL array
  code: |-
    mockData.option = 'key';
    mockData.keyName = 'ecommerce.impression.0.name';

    mock('copyFromDataLayer', key => {
      return 1;
    });

    mock('copyFromWindow', key => {
      return dataLayer;
    });

    // Call runCode to run the template's code.
    const variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('product_name1');
- name: Fetches OBJECT from template dL array
  code: |-
    mock('copyFromDataLayer', key => {
      return 2;
    });

    mock('copyFromWindow', key => {
      return dataLayer;
    });

    // Call runCode to run the template's code.
    const variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo({'gtm.uniqueEventId': 2, event: 'Event1', secondItem: {test: 'no'}, ecommerce: {impression:[{name: 'product_name2'}]}});
- name: Fetches KEY from template dL array
  code: |-
    mockData.option = 'key';
    mockData.keyName = 'ecommerce.impression.0.name';

    mock('copyFromDataLayer', key => {
      return 2;
    });

    mock('copyFromWindow', key => {
      return dataLayer;
    });

    // Call runCode to run the template's code.
    const variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('product_name2');
- name: Fetches OBJECT from specif occurency in regular dL array
  code: |-
    mockData.mapEvent= '1';
    mockData.eventIdx = 2;

    mock('copyFromDataLayer', key => {
      return 1;
    });

    mock('copyFromWindow', key => {
      return dataLayer;
    });

    // Call runCode to run the template's code.
    const variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo({'gtm.uniqueEventId': 2, event: 'Event1', secondItem: {test: 'no'}, ecommerce: {impression:[{name: 'product_name2'}]}});
- name: Fetches KEY from specif occurency in regular dL array
  code: |-
    mockData.option = 'key';
    mockData.keyName = 'ecommerce.impression.0.name';
    mockData.mapEvent= '1';
    mockData.eventIdx = 2;

    mock('copyFromDataLayer', key => {
      return 1;
    });

    mock('copyFromWindow', key => {
      return dataLayer;
    });

    // Call runCode to run the template's code.
    const variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    // Verify that the variable returns a result.
    /*assertThat(variableResult).isEqualTo({'gtm.uniqueEventId': 2, event: 'Event1', secondItem: {test: 'no'}, ecommerce: {impression:[{name: 'product_name2'}]}});*/
    assertThat(variableResult).isEqualTo('product_name2');
- name: Fetches OBJECT from specif event and specif occurency in regular dL array
  code: |-
    mockData.mapEvent= '2';
    mockData.eventIdx = 2;
    mockData.eventName = "Event2";

    mock('copyFromDataLayer', key => {
      return 1;
    });

    mock('copyFromWindow', key => {
      return dataLayer;
    });

    // Call runCode to run the template's code.
    const variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo({'gtm.uniqueEventId': 6, event: 'Event2', secondItem: {test: 'no'}, ecommerce: {impression:[{name: 'product_name6'}]}});
- name: Fetches KEY from specif event and specif occurency in regular dL array
  code: |-
    mockData.option = 'key';
    mockData.keyName = 'ecommerce.impression.0.name';
    mockData.mapEvent= '2';
    mockData.eventIdx = 2;
    mockData.eventName = "Event2";

    mock('copyFromDataLayer', key => {
      return 1;
    });

    mock('copyFromWindow', key => {
      return dataLayer;
    });

    // Call runCode to run the template's code.
    const variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    // Verify that the variable returns a result.
    /*assertThat(variableResult).isEqualTo({'gtm.uniqueEventId': 2, event: 'Event1', secondItem: {test: 'no'}, ecommerce: {impression:[{name: 'product_name2'}]}});*/
    assertThat(variableResult).isEqualTo('product_name6');
- name: Fetches OBJECT from first occurency of specif Event in regular dL array
  code: |-
    mockData.mapEvent= '3';
    mockData.eventName = "Event2";

    mock('copyFromDataLayer', key => {
      return 1;
    });

    mock('copyFromWindow', key => {
      return dataLayer;
    });

    // Call runCode to run the template's code.
    const variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo({'gtm.uniqueEventId': 5, event: 'Event2', firstItem: {test: 'yes'}, ecommerce: {impression:[{name: 'product_name5'}]}});
- name: Fetches KEY from first occurency of specif Event in regular dL array
  code: |-
    mockData.option = 'key';
    mockData.keyName = 'ecommerce.impression.0.name';
    mockData.mapEvent= '3';
    mockData.eventName = "Event2";

    mock('copyFromDataLayer', key => {
      return 1;
    });

    mock('copyFromWindow', key => {
      return dataLayer;
    });

    // Call runCode to run the template's code.
    const variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    // Verify that the variable returns a result.
    /*assertThat(variableResult).isEqualTo({'gtm.uniqueEventId': 2, event: 'Event1', secondItem: {test: 'no'}, ecommerce: {impression:[{name: 'product_name2'}]}});*/
    assertThat(variableResult).isEqualTo('product_name5');
- name: Fetches OBJECT from penult occurency of specif Event in regular dL array
  code: |-
    mockData.mapEvent= '4';
    mockData.eventName = "Event1";

    mock('copyFromDataLayer', key => {
      return 1;
    });

    mock('copyFromWindow', key => {
      return dataLayer;
    });

    // Call runCode to run the template's code.
    const variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo({'gtm.uniqueEventId':3, event: 'Event1', firstItem: {test: 'yes'}, ecommerce: {impression:[{name: 'product_name3'}]}});
- name: Fetches KEY from penult occurency of specif Event in regular dL array
  code: |-
    mockData.option = 'key';
    mockData.keyName = 'ecommerce.impression.0.name';
    mockData.mapEvent= '4';
    mockData.eventName = "Event1";

    mock('copyFromDataLayer', key => {
      return 1;
    });

    mock('copyFromWindow', key => {
      return dataLayer;
    });

    // Call runCode to run the template's code.
    const variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    // Verify that the variable returns a result.
    /*assertThat(variableResult).isEqualTo({'gtm.uniqueEventId': 2, event: 'Event1', secondItem: {test: 'no'}, ecommerce: {impression:[{name: 'product_name2'}]}});*/
    assertThat(variableResult).isEqualTo('product_name3');
- name: Fetches KEY from last occurency of specif Event in regular dL array
  code: |-
    mockData.option = 'key';
    mockData.keyName = 'ecommerce.impression.0.name';
    mockData.mapEvent= '5';
    mockData.eventName = "Event2";

    mock('copyFromDataLayer', key => {
      return 1;
    });

    mock('copyFromWindow', key => {
      return dataLayer;
    });

    // Call runCode to run the template's code.
    const variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    // Verify that the variable returns a result.
    /*assertThat(variableResult).isEqualTo({'gtm.uniqueEventId': 2, event: 'Event1', secondItem: {test: 'no'}, ecommerce: {impression:[{name: 'product_name2'}]}});*/
    assertThat(variableResult).isEqualTo('product_name8');
- name: Fetches OBJECT from last occurency of specif Event in regular dL array
  code: |-
    mockData.mapEvent= '5';
    mockData.eventName = "Event2";

    mock('copyFromDataLayer', key => {
      return 1;
    });

    mock('copyFromWindow', key => {
      return dataLayer;
    });

    // Call runCode to run the template's code.
    const variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo({'gtm.uniqueEventId': 8, event: 'Event2', secondItem: {test: 'no'}, ecommerce: {impression:[{name: 'product_name8'}]}});
setup: |-
  const mockData = {
    option: 'object',
    keyName: 'ecommerce.impression.0.name',
    mapEvent: 'no'
  };

  const dataLayer = [{
    'gtm.uniqueEventId': 1,
    event: 'Event1',
    firstItem: {
      test: 'yes'
    },
    ecommerce: {impression:[{name: 'product_name1'}]}
  },{
    a: {
      'gtm.uniqueEventId': 2,
      event: 'Event1',
      secondItem: {
        test: 'no'
      },
      ecommerce: {impression:[{name: 'product_name2'}]}
    }
  },{
    'gtm.uniqueEventId': 3,
    event: 'Event1',
    firstItem: {
      test: 'yes'
    },
    ecommerce: {impression:[{name: 'product_name3'}]}
  },{
    a: {
      'gtm.uniqueEventId': 4,
      event: 'Event1',
      secondItem: {
        test: 'no'
      },
      ecommerce: {impression:[{name: 'product_name4'}]}
    }
  },{
    'gtm.uniqueEventId': 5,
    event: 'Event2',
    firstItem: {
      test: 'yes'
    },
    ecommerce: {impression:[{name: 'product_name5'}]}
  },{
    a: {
      'gtm.uniqueEventId': 6,
      event: 'Event2',
      secondItem: {
        test: 'no'
      },
      ecommerce: {impression:[{name: 'product_name6'}]}
    }
  },{
    'gtm.uniqueEventId': 7,
    event: 'Event2',
    firstItem: {
      test: 'yes'
    },
    ecommerce: {impression:[{name: 'product_name7'}]}
  },{
    a: {
      'gtm.uniqueEventId': 8,
      event: 'Event2',
      secondItem: {
        test: 'no'
      },
      ecommerce: {impression:[{name: 'product_name8'}]}
    }
  }];


___NOTES___

Created on 25/02/2021, 19:33:41
Updated on 26/02/2021, 20:00:00