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
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const copyFromDataLayer = require('copyFromDataLayer');
const copyFromWindow = require('copyFromWindow');
const JSON = require('JSON');
const log = require('logToConsole');

const gtmId = copyFromDataLayer('gtm.uniqueEventId');
const dataLayer = copyFromWindow('dataLayer');

// Helper inspired by https://bit.ly/3bAAz32
const get = (obj, path, def) => {
  path = path.split('.');
  let current = obj;
  
  for (let i = 0; i < path.length; i++) {
    if (!current[path[i]]) return def;
    current = current[path[i]];
  }
  return current;
};

if (dataLayer && gtmId) {
  // Get object from dataLayer that matches the gtm.uniqueEventId
  let obj = dataLayer.map(o => {
    // If a regular dataLayer object, return it
    if (o['gtm.uniqueEventId']) return o;
    // Other wise assume it's a template constructor-based object
    // Clone the object to remove constructor, then return first
    // property in the object (the wrapper).
    o = JSON.parse(JSON.stringify(o));
    for (let prop in o) {
      return o[prop];
    }
  }).filter(o => {
    // Filter to only include the item(s) where the event ID matches
    if (o['gtm.uniqueEventId'] === gtmId) return true;
  });
  // Get the first item from the matches
  obj = obj.length ? obj[0] : {};
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
                "string": "gtm.uniqueEventId"
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
- name: Fetches object from regular dL array
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
    assertThat(variableResult).isEqualTo({'gtm.uniqueEventId': 1, firstItem: {test: 'yes'}});
- name: Fetches object from template dL array
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
    assertThat(variableResult).isEqualTo({'gtm.uniqueEventId': 2, secondItem: {test: 'no'}});
- name: Fetches key from regular dL array
  code: |-
    mockData.option = 'key';
    mockData.keyName = 'firstItem.test';

    mock('copyFromDataLayer', key => {
      return 1;
    });

    mock('copyFromWindow', key => {
      return dataLayer;
    });

    // Call runCode to run the template's code.
    const variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('yes');
- name: Fetches key from template dL array
  code: |-
    mockData.option = 'key';
    mockData.keyName = 'secondItem.test';

    mock('copyFromDataLayer', key => {
      return 2;
    });

    mock('copyFromWindow', key => {
      return dataLayer;
    });

    // Call runCode to run the template's code.
    const variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('no');
setup: |-
  const mockData = {
    option: 'object'
  };

  const dataLayer = [{
    'gtm.uniqueEventId': 1,
    firstItem: {
      test: 'yes'
    }
  },{
    a: {
      'gtm.uniqueEventId': 2,
      secondItem: {
        test: 'no'
      }
    }
  }];


___NOTES___

Created on 25/02/2021, 19:33:41


