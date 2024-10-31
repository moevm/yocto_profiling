Для дефолтного конфига сборки образа Yocto были проведены тесты с различным количеством кэш серверов и одним хэш сервером. Количество кэш серверов варьировалось от 2 до 53 включительно, к тому же для каждого кол-ва было проведено 4 эксперимента. 

### Аномалии
Пробежав глазами по результатам наблюдается линейный рост каждой из метрик. Но есть и несколько аномальных значений, например:
Для 26 серверов, запуск №1:
Нормальные значения, вписывающиеся в линейную зависимость для этого кол-ва серверов.
```json
{
    "time": 635,
    "sstate_checking": 361,
    "without_checking": 274
}
```

Аномальные значения на 1 запуске:
```json
{
    "time": 1613,
    "sstate_checking": 362,
    "without_checking": 1251
}
```

Для 29 серверов, запуск №5:
Нормальные значения, вписывающиеся в линейную зависимость для этого кол-ва серверов.
```json
{
    "time": 686,
    "sstate_checking": 400,
    "without_checking": 286
}
```

Аномальные значения на 1 запуске:
```json
{
    "time": 2384,
    "sstate_checking": 394,
    "without_checking": 1990
}
```

Видно, что время затраченное на сверку сигнатур в точно вписывается в нормы, а вот время сборки превышает пределы настолько, что можно предположить, что сборка производилась без кэш серверов. Полагаю, что это как-то связано с нагрузкой сети в лаборатории, так что эти значения не будем использовать для расчёта среднего. Получим:
```json
// 26 servers
{
    "avg_time": 640.75,
    "avg_sstate_checking": 359.2,
    "avg_without_checking": 276.25
}
// 29 servers
{
    "avg_time": 688.25,
    "avg_sstate_checking": 396.6,
    "avg_without_checking": 291.0
}
```

### Данные используемые в построении графиков

| servers_num | avg_time | avg_sstate_checking | avg_without_checking |
| :----------: | :-------: | :------------------: | :-------------------: |
|           2 |    263.2 |                  34.0 |                229.2 |
|           3 |    286.6 |                45.8 |                240.8 |
|           4 |    306.2 |                58.2 |                  248.0 |
|           5 |    362.2 |                71.6 |                290.6 |
|           6 |      331.0 |                83.8 |                247.2 |
|           7 |    340.2 |                  97.0 |                243.2 |
|           8 |    356.2 |                 111.0 |                245.2 |
|           9 |    368.4 |                 124.0 |                244.4 |
|          10 |      383.0 |               135.4 |                247.6 |
|          11 |      397.0 |                 151.0 |                  246.0 |
|          12 |      410.0 |                 164.0 |                  246.0 |
|          13 |    432.8 |               178.8 |                  254.0 |
|          14 |    448.6 |               193.4 |                255.2 |
|          15 |    464.8 |               208.8 |                  256.0 |
|          16 |    498.6 |               221.2 |                277.4 |
|          17 |    494.4 |               235.2 |                259.2 |
|          18 |    513.2 |               248.8 |                264.4 |
|          19 |    531.8 |                 259.0 |                272.8 |
|          20 |    545.2 |               275.4 |                269.8 |
|          21 |    562.4 |               285.6 |                276.8 |
|          22 |    586.8 |               305.2 |                281.6 |
|          23 |      594.0 |               319.2 |                274.8 |
|          24 |    603.4 |               329.2 |                274.2 |
|          25 |    627.8 |               334.2 |                293.6 |
|          26 |   640.75 |               359.2 |               276.25 |
|          27 |    650.8 |               373.2 |                277.6 |
|          28 |    661.8 |               377.6 |                284.2 |
|          29 |   688.25 |               396.6 |                  291.0 |
|          30 |    703.8 |               410.2 |                293.6 |
|          31 |      748.0 |               422.4 |                325.6 |
|          32 |    742.4 |               435.8 |                306.6 |
|          33 |    767.4 |               457.8 |                309.6 |
|          34 |    786.2 |               461.8 |                324.4 |
|          35 |    801.2 |               474.6 |                326.6 |
|          36 |    813.8 |               486.8 |                  327.0 |
|          37 |    832.8 |               498.8 |                  334.0 |
|          38 |      848.0 |                 515.0 |                  333.0 |
|          39 |    866.2 |               533.8 |                332.4 |
|          40 |    889.4 |               541.2 |                348.2 |
|          41 |    895.4 |               549.6 |                345.8 |
|          42 |    912.4 |               561.8 |                350.6 |
|          43 |    932.8 |               579.2 |                353.6 |
|          44 |    954.8 |               591.2 |                363.6 |
|          45 |    974.4 |                 607.0 |                367.4 |
|          46 |    972.6 |               604.2 |                368.4 |
|          47 |    990.6 |               617.6 |                  373.0 |
|          48 |   1013.4 |               630.4 |                  383.0 |
|          49 |   1045.4 |               642.4 |                  403.0 |
|          50 |     1058.0 |               659.2 |                398.8 |
|          51 |   1082.4 |                 675.0 |                407.4 |
|          52 |   1113.8 |               689.4 |                424.4 |
|          53 |   1130.6 |               697.4 |                433.2 |

### Графики
![](wiki/experiments/experiment_results/avg_build_time.png)

![](wiki/experiments/experiment_results/avg_build_time_no_sstate.png)

![](wiki/experiments/experiment_results/avg_sstate_time.png)

![](wiki/experiments/experiment_results/all.png)

### Результаты
Cхема результата:
```json
{
	"count_of_servers": {
		"repeat_num": {
			"stats" : ...
		}
	}
}
```
 
 Результат:
```json
{
    "2": {
        "1": {
            "time": 265,
            "sstate_checking": 34,
            "without_checking": 231
        },
        "2": {
            "time": 261,
            "sstate_checking": 34,
            "without_checking": 227
        },
        "3": {
            "time": 261,
            "sstate_checking": 34,
            "without_checking": 227
        },
        "4": {
            "time": 263,
            "sstate_checking": 34,
            "without_checking": 229
        },
        "5": {
            "time": 266,
            "sstate_checking": 34,
            "without_checking": 232
        }
    },
    "3": {
        "1": {
            "time": 309,
            "sstate_checking": 45,
            "without_checking": 264
        },
        "2": {
            "time": 280,
            "sstate_checking": 46,
            "without_checking": 234
        },
        "3": {
            "time": 284,
            "sstate_checking": 46,
            "without_checking": 238
        },
        "4": {
            "time": 280,
            "sstate_checking": 46,
            "without_checking": 234
        },
        "5": {
            "time": 280,
            "sstate_checking": 46,
            "without_checking": 234
        }
    },
    "4": {
        "1": {
            "time": 296,
            "sstate_checking": 58,
            "without_checking": 238
        },
        "2": {
            "time": 285,
            "sstate_checking": 59,
            "without_checking": 226
        },
        "3": {
            "time": 287,
            "sstate_checking": 58,
            "without_checking": 229
        },
        "4": {
            "time": 370,
            "sstate_checking": 58,
            "without_checking": 312
        },
        "5": {
            "time": 293,
            "sstate_checking": 58,
            "without_checking": 235
        }
    },
    "5": {
        "1": {
            "time": 322,
            "sstate_checking": 71,
            "without_checking": 251
        },
        "2": {
            "time": 315,
            "sstate_checking": 72,
            "without_checking": 243
        },
        "3": {
            "time": 312,
            "sstate_checking": 72,
            "without_checking": 240
        },
        "4": {
            "time": 309,
            "sstate_checking": 72,
            "without_checking": 237
        },
        "5": {
            "time": 553,
            "sstate_checking": 71,
            "without_checking": 482
        }
    },
    "6": {
        "1": {
            "time": 318,
            "sstate_checking": 83,
            "without_checking": 235
        },
        "2": {
            "time": 319,
            "sstate_checking": 84,
            "without_checking": 235
        },
        "3": {
            "time": 324,
            "sstate_checking": 84,
            "without_checking": 240
        },
        "4": {
            "time": 322,
            "sstate_checking": 84,
            "without_checking": 238
        },
        "5": {
            "time": 372,
            "sstate_checking": 84,
            "without_checking": 288
        }
    },
    "7": {
        "1": {
            "time": 346,
            "sstate_checking": 97,
            "without_checking": 249
        },
        "2": {
            "time": 343,
            "sstate_checking": 97,
            "without_checking": 246
        },
        "3": {
            "time": 337,
            "sstate_checking": 97,
            "without_checking": 240
        },
        "4": {
            "time": 336,
            "sstate_checking": 97,
            "without_checking": 239
        },
        "5": {
            "time": 339,
            "sstate_checking": 97,
            "without_checking": 242
        }
    },
    "8": {
        "1": {
            "time": 350,
            "sstate_checking": 111,
            "without_checking": 239
        },
        "2": {
            "time": 353,
            "sstate_checking": 111,
            "without_checking": 242
        },
        "3": {
            "time": 353,
            "sstate_checking": 111,
            "without_checking": 242
        },
        "4": {
            "time": 350,
            "sstate_checking": 111,
            "without_checking": 239
        },
        "5": {
            "time": 375,
            "sstate_checking": 111,
            "without_checking": 264
        }
    },
    "9": {
        "1": {
            "time": 378,
            "sstate_checking": 125,
            "without_checking": 253
        },
        "2": {
            "time": 366,
            "sstate_checking": 124,
            "without_checking": 242
        },
        "3": {
            "time": 368,
            "sstate_checking": 124,
            "without_checking": 244
        },
        "4": {
            "time": 364,
            "sstate_checking": 123,
            "without_checking": 241
        },
        "5": {
            "time": 366,
            "sstate_checking": 124,
            "without_checking": 242
        }
    },
    "10": {
        "1": {
            "time": 378,
            "sstate_checking": 134,
            "without_checking": 244
        },
        "2": {
            "time": 377,
            "sstate_checking": 135,
            "without_checking": 242
        },
        "3": {
            "time": 382,
            "sstate_checking": 136,
            "without_checking": 246
        },
        "4": {
            "time": 387,
            "sstate_checking": 136,
            "without_checking": 251
        },
        "5": {
            "time": 391,
            "sstate_checking": 136,
            "without_checking": 255
        }
    },
    "11": {
        "1": {
            "time": 397,
            "sstate_checking": 151,
            "without_checking": 246
        },
        "2": {
            "time": 397,
            "sstate_checking": 152,
            "without_checking": 245
        },
        "3": {
            "time": 393,
            "sstate_checking": 150,
            "without_checking": 243
        },
        "4": {
            "time": 392,
            "sstate_checking": 151,
            "without_checking": 241
        },
        "5": {
            "time": 406,
            "sstate_checking": 151,
            "without_checking": 255
        }
    },
    "12": {
        "1": {
            "time": 410,
            "sstate_checking": 165,
            "without_checking": 245
        },
        "2": {
            "time": 408,
            "sstate_checking": 164,
            "without_checking": 244
        },
        "3": {
            "time": 411,
            "sstate_checking": 164,
            "without_checking": 247
        },
        "4": {
            "time": 407,
            "sstate_checking": 163,
            "without_checking": 244
        },
        "5": {
            "time": 414,
            "sstate_checking": 164,
            "without_checking": 250
        }
    },
    "13": {
        "1": {
            "time": 445,
            "sstate_checking": 180,
            "without_checking": 265
        },
        "2": {
            "time": 434,
            "sstate_checking": 179,
            "without_checking": 255
        },
        "3": {
            "time": 429,
            "sstate_checking": 178,
            "without_checking": 251
        },
        "4": {
            "time": 426,
            "sstate_checking": 179,
            "without_checking": 247
        },
        "5": {
            "time": 430,
            "sstate_checking": 178,
            "without_checking": 252
        }
    },
    "14": {
        "1": {
            "time": 444,
            "sstate_checking": 193,
            "without_checking": 251
        },
        "2": {
            "time": 446,
            "sstate_checking": 194,
            "without_checking": 252
        },
        "3": {
            "time": 465,
            "sstate_checking": 194,
            "without_checking": 271
        },
        "4": {
            "time": 446,
            "sstate_checking": 193,
            "without_checking": 253
        },
        "5": {
            "time": 442,
            "sstate_checking": 193,
            "without_checking": 249
        }
    },
    "15": {
        "1": {
            "time": 454,
            "sstate_checking": 209,
            "without_checking": 245
        },
        "2": {
            "time": 459,
            "sstate_checking": 209,
            "without_checking": 250
        },
        "3": {
            "time": 461,
            "sstate_checking": 208,
            "without_checking": 253
        },
        "4": {
            "time": 486,
            "sstate_checking": 210,
            "without_checking": 276
        },
        "5": {
            "time": 464,
            "sstate_checking": 208,
            "without_checking": 256
        }
    },
    "16": {
        "1": {
            "time": 472,
            "sstate_checking": 222,
            "without_checking": 250
        },
        "2": {
            "time": 480,
            "sstate_checking": 220,
            "without_checking": 260
        },
        "3": {
            "time": 472,
            "sstate_checking": 222,
            "without_checking": 250
        },
        "4": {
            "time": 585,
            "sstate_checking": 221,
            "without_checking": 364
        },
        "5": {
            "time": 484,
            "sstate_checking": 221,
            "without_checking": 263
        }
    },
    "17": {
        "1": {
            "time": 492,
            "sstate_checking": 237,
            "without_checking": 255
        },
        "2": {
            "time": 497,
            "sstate_checking": 234,
            "without_checking": 263
        },
        "3": {
            "time": 495,
            "sstate_checking": 235,
            "without_checking": 260
        },
        "4": {
            "time": 494,
            "sstate_checking": 234,
            "without_checking": 260
        },
        "5": {
            "time": 494,
            "sstate_checking": 236,
            "without_checking": 258
        }
    },
    "18": {
        "1": {
            "time": 534,
            "sstate_checking": 249,
            "without_checking": 285
        },
        "2": {
            "time": 512,
            "sstate_checking": 249,
            "without_checking": 263
        },
        "3": {
            "time": 510,
            "sstate_checking": 250,
            "without_checking": 260
        },
        "4": {
            "time": 504,
            "sstate_checking": 247,
            "without_checking": 257
        },
        "5": {
            "time": 506,
            "sstate_checking": 249,
            "without_checking": 257
        }
    },
    "19": {
        "1": {
            "time": 536,
            "sstate_checking": 260,
            "without_checking": 276
        },
        "2": {
            "time": 531,
            "sstate_checking": 259,
            "without_checking": 272
        },
        "3": {
            "time": 550,
            "sstate_checking": 257,
            "without_checking": 293
        },
        "4": {
            "time": 525,
            "sstate_checking": 259,
            "without_checking": 266
        },
        "5": {
            "time": 517,
            "sstate_checking": 260,
            "without_checking": 257
        }
    },
    "20": {
        "1": {
            "time": 539,
            "sstate_checking": 275,
            "without_checking": 264
        },
        "2": {
            "time": 562,
            "sstate_checking": 275,
            "without_checking": 287
        },
        "3": {
            "time": 539,
            "sstate_checking": 274,
            "without_checking": 265
        },
        "4": {
            "time": 541,
            "sstate_checking": 276,
            "without_checking": 265
        },
        "5": {
            "time": 545,
            "sstate_checking": 277,
            "without_checking": 268
        }
    },
    "21": {
        "1": {
            "time": 564,
            "sstate_checking": 292,
            "without_checking": 272
        },
        "2": {
            "time": 577,
            "sstate_checking": 288,
            "without_checking": 289
        },
        "3": {
            "time": 560,
            "sstate_checking": 291,
            "without_checking": 269
        },
        "4": {
            "time": 543,
            "sstate_checking": 266,
            "without_checking": 277
        },
        "5": {
            "time": 568,
            "sstate_checking": 291,
            "without_checking": 277
        }
    },
    "22": {
        "1": {
            "time": 584,
            "sstate_checking": 306,
            "without_checking": 278
        },
        "2": {
            "time": 601,
            "sstate_checking": 303,
            "without_checking": 298
        },
        "3": {
            "time": 585,
            "sstate_checking": 304,
            "without_checking": 281
        },
        "4": {
            "time": 577,
            "sstate_checking": 305,
            "without_checking": 272
        },
        "5": {
            "time": 587,
            "sstate_checking": 308,
            "without_checking": 279
        }
    },
    "23": {
        "1": {
            "time": 605,
            "sstate_checking": 320,
            "without_checking": 285
        },
        "2": {
            "time": 614,
            "sstate_checking": 316,
            "without_checking": 298
        },
        "3": {
            "time": 582,
            "sstate_checking": 317,
            "without_checking": 265
        },
        "4": {
            "time": 581,
            "sstate_checking": 321,
            "without_checking": 260
        },
        "5": {
            "time": 588,
            "sstate_checking": 322,
            "without_checking": 266
        }
    },
    "24": {
        "1": {
            "time": 596,
            "sstate_checking": 331,
            "without_checking": 265
        },
        "2": {
            "time": 621,
            "sstate_checking": 322,
            "without_checking": 299
        },
        "3": {
            "time": 606,
            "sstate_checking": 333,
            "without_checking": 273
        },
        "4": {
            "time": 598,
            "sstate_checking": 329,
            "without_checking": 269
        },
        "5": {
            "time": 596,
            "sstate_checking": 331,
            "without_checking": 265
        }
    },
    "25": {
        "1": {
            "time": 701,
            "sstate_checking": 346,
            "without_checking": 355
        },
        "2": {
            "time": 635,
            "sstate_checking": 338,
            "without_checking": 297
        },
        "3": {
            "time": 615,
            "sstate_checking": 343,
            "without_checking": 272
        },
        "4": {
            "time": 615,
            "sstate_checking": 343,
            "without_checking": 272
        },
        "5": {
            "time": 573,
            "sstate_checking": 301,
            "without_checking": 272
        }
    },
    "26": {
        "1": {
            "time": 1613,
            "sstate_checking": 362,
            "without_checking": 1251
        },
        "2": {
            "time": 635,
            "sstate_checking": 361,
            "without_checking": 274
        },
        "3": {
            "time": 634,
            "sstate_checking": 358,
            "without_checking": 276
        },
        "4": {
            "time": 630,
            "sstate_checking": 358,
            "without_checking": 272
        },
        "5": {
            "time": 640,
            "sstate_checking": 357,
            "without_checking": 283
        }
    },
    "27": {
        "1": {
            "time": 646,
            "sstate_checking": 372,
            "without_checking": 274
        },
        "2": {
            "time": 650,
            "sstate_checking": 375,
            "without_checking": 275
        },
        "3": {
            "time": 655,
            "sstate_checking": 370,
            "without_checking": 285
        },
        "4": {
            "time": 651,
            "sstate_checking": 376,
            "without_checking": 275
        },
        "5": {
            "time": 652,
            "sstate_checking": 373,
            "without_checking": 279
        }
    },
    "28": {
        "1": {
            "time": 664,
            "sstate_checking": 380,
            "without_checking": 284
        },
        "2": {
            "time": 677,
            "sstate_checking": 376,
            "without_checking": 301
        },
        "3": {
            "time": 658,
            "sstate_checking": 376,
            "without_checking": 282
        },
        "4": {
            "time": 650,
            "sstate_checking": 373,
            "without_checking": 277
        },
        "5": {
            "time": 660,
            "sstate_checking": 383,
            "without_checking": 277
        }
    },
    "29": {
        "1": {
            "time": 702,
            "sstate_checking": 393,
            "without_checking": 309
        },
        "2": {
            "time": 682,
            "sstate_checking": 398,
            "without_checking": 284
        },
        "3": {
            "time": 683,
            "sstate_checking": 398,
            "without_checking": 285
        },
        "4": {
            "time": 686,
            "sstate_checking": 400,
            "without_checking": 286
        },
        "5": {
            "time": 2384,
            "sstate_checking": 394,
            "without_checking": 1990
        }
    },
    "30": {
        "1": {
            "time": 694,
            "sstate_checking": 407,
            "without_checking": 287
        },
        "2": {
            "time": 704,
            "sstate_checking": 414,
            "without_checking": 290
        },
        "3": {
            "time": 721,
            "sstate_checking": 404,
            "without_checking": 317
        },
        "4": {
            "time": 696,
            "sstate_checking": 410,
            "without_checking": 286
        },
        "5": {
            "time": 704,
            "sstate_checking": 416,
            "without_checking": 288
        }
    },
    "31": {
        "1": {
            "time": 789,
            "sstate_checking": 428,
            "without_checking": 361
        },
        "2": {
            "time": 726,
            "sstate_checking": 410,
            "without_checking": 316
        },
        "3": {
            "time": 717,
            "sstate_checking": 427,
            "without_checking": 290
        },
        "4": {
            "time": 717,
            "sstate_checking": 425,
            "without_checking": 292
        },
        "5": {
            "time": 791,
            "sstate_checking": 422,
            "without_checking": 369
        }
    },
    "32": {
        "1": {
            "time": 745,
            "sstate_checking": 435,
            "without_checking": 310
        },
        "2": {
            "time": 740,
            "sstate_checking": 439,
            "without_checking": 301
        },
        "3": {
            "time": 733,
            "sstate_checking": 437,
            "without_checking": 296
        },
        "4": {
            "time": 737,
            "sstate_checking": 436,
            "without_checking": 301
        },
        "5": {
            "time": 757,
            "sstate_checking": 432,
            "without_checking": 325
        }
    },
    "33": {
        "1": {
            "time": 761,
            "sstate_checking": 457,
            "without_checking": 304
        },
        "2": {
            "time": 762,
            "sstate_checking": 461,
            "without_checking": 301
        },
        "3": {
            "time": 773,
            "sstate_checking": 462,
            "without_checking": 311
        },
        "4": {
            "time": 777,
            "sstate_checking": 452,
            "without_checking": 325
        },
        "5": {
            "time": 764,
            "sstate_checking": 457,
            "without_checking": 307
        }
    },
    "34": {
        "1": {
            "time": 775,
            "sstate_checking": 468,
            "without_checking": 307
        },
        "2": {
            "time": 830,
            "sstate_checking": 458,
            "without_checking": 372
        },
        "3": {
            "time": 777,
            "sstate_checking": 454,
            "without_checking": 323
        },
        "4": {
            "time": 777,
            "sstate_checking": 463,
            "without_checking": 314
        },
        "5": {
            "time": 772,
            "sstate_checking": 466,
            "without_checking": 306
        }
    },
    "35": {
        "1": {
            "time": 789,
            "sstate_checking": 475,
            "without_checking": 314
        },
        "2": {
            "time": 790,
            "sstate_checking": 480,
            "without_checking": 310
        },
        "3": {
            "time": 849,
            "sstate_checking": 477,
            "without_checking": 372
        },
        "4": {
            "time": 779,
            "sstate_checking": 461,
            "without_checking": 318
        },
        "5": {
            "time": 799,
            "sstate_checking": 480,
            "without_checking": 319
        }
    },
    "36": {
        "1": {
            "time": 812,
            "sstate_checking": 484,
            "without_checking": 328
        },
        "2": {
            "time": 810,
            "sstate_checking": 491,
            "without_checking": 319
        },
        "3": {
            "time": 809,
            "sstate_checking": 496,
            "without_checking": 313
        },
        "4": {
            "time": 842,
            "sstate_checking": 480,
            "without_checking": 362
        },
        "5": {
            "time": 796,
            "sstate_checking": 483,
            "without_checking": 313
        }
    },
    "37": {
        "1": {
            "time": 828,
            "sstate_checking": 504,
            "without_checking": 324
        },
        "2": {
            "time": 890,
            "sstate_checking": 509,
            "without_checking": 381
        },
        "3": {
            "time": 807,
            "sstate_checking": 480,
            "without_checking": 327
        },
        "4": {
            "time": 817,
            "sstate_checking": 497,
            "without_checking": 320
        },
        "5": {
            "time": 822,
            "sstate_checking": 504,
            "without_checking": 318
        }
    },
    "38": {
        "1": {
            "time": 866,
            "sstate_checking": 505,
            "without_checking": 361
        },
        "2": {
            "time": 838,
            "sstate_checking": 513,
            "without_checking": 325
        },
        "3": {
            "time": 851,
            "sstate_checking": 521,
            "without_checking": 330
        },
        "4": {
            "time": 840,
            "sstate_checking": 516,
            "without_checking": 324
        },
        "5": {
            "time": 845,
            "sstate_checking": 520,
            "without_checking": 325
        }
    },
    "39": {
        "1": {
            "time": 869,
            "sstate_checking": 537,
            "without_checking": 332
        },
        "2": {
            "time": 867,
            "sstate_checking": 532,
            "without_checking": 335
        },
        "3": {
            "time": 870,
            "sstate_checking": 537,
            "without_checking": 333
        },
        "4": {
            "time": 859,
            "sstate_checking": 529,
            "without_checking": 330
        },
        "5": {
            "time": 866,
            "sstate_checking": 534,
            "without_checking": 332
        }
    },
    "40": {
        "1": {
            "time": 878,
            "sstate_checking": 544,
            "without_checking": 334
        },
        "2": {
            "time": 891,
            "sstate_checking": 542,
            "without_checking": 349
        },
        "3": {
            "time": 880,
            "sstate_checking": 537,
            "without_checking": 343
        },
        "4": {
            "time": 890,
            "sstate_checking": 545,
            "without_checking": 345
        },
        "5": {
            "time": 908,
            "sstate_checking": 538,
            "without_checking": 370
        }
    },
    "41": {
        "1": {
            "time": 887,
            "sstate_checking": 549,
            "without_checking": 338
        },
        "2": {
            "time": 895,
            "sstate_checking": 549,
            "without_checking": 346
        },
        "3": {
            "time": 899,
            "sstate_checking": 550,
            "without_checking": 349
        },
        "4": {
            "time": 894,
            "sstate_checking": 547,
            "without_checking": 347
        },
        "5": {
            "time": 902,
            "sstate_checking": 553,
            "without_checking": 349
        }
    },
    "42": {
        "1": {
            "time": 904,
            "sstate_checking": 557,
            "without_checking": 347
        },
        "2": {
            "time": 903,
            "sstate_checking": 554,
            "without_checking": 349
        },
        "3": {
            "time": 904,
            "sstate_checking": 559,
            "without_checking": 345
        },
        "4": {
            "time": 924,
            "sstate_checking": 569,
            "without_checking": 355
        },
        "5": {
            "time": 927,
            "sstate_checking": 570,
            "without_checking": 357
        }
    },
    "43": {
        "1": {
            "time": 942,
            "sstate_checking": 589,
            "without_checking": 353
        },
        "2": {
            "time": 925,
            "sstate_checking": 575,
            "without_checking": 350
        },
        "3": {
            "time": 943,
            "sstate_checking": 582,
            "without_checking": 361
        },
        "4": {
            "time": 931,
            "sstate_checking": 580,
            "without_checking": 351
        },
        "5": {
            "time": 923,
            "sstate_checking": 570,
            "without_checking": 353
        }
    },
    "44": {
        "1": {
            "time": 959,
            "sstate_checking": 599,
            "without_checking": 360
        },
        "2": {
            "time": 963,
            "sstate_checking": 596,
            "without_checking": 367
        },
        "3": {
            "time": 924,
            "sstate_checking": 563,
            "without_checking": 361
        },
        "4": {
            "time": 963,
            "sstate_checking": 599,
            "without_checking": 364
        },
        "5": {
            "time": 965,
            "sstate_checking": 599,
            "without_checking": 366
        }
    },
    "45": {
        "1": {
            "time": 978,
            "sstate_checking": 609,
            "without_checking": 369
        },
        "2": {
            "time": 963,
            "sstate_checking": 601,
            "without_checking": 362
        },
        "3": {
            "time": 971,
            "sstate_checking": 599,
            "without_checking": 372
        },
        "4": {
            "time": 976,
            "sstate_checking": 610,
            "without_checking": 366
        },
        "5": {
            "time": 984,
            "sstate_checking": 616,
            "without_checking": 368
        }
    },
    "46": {
        "1": {
            "time": 974,
            "sstate_checking": 605,
            "without_checking": 369
        },
        "2": {
            "time": 974,
            "sstate_checking": 605,
            "without_checking": 369
        },
        "3": {
            "time": 973,
            "sstate_checking": 604,
            "without_checking": 369
        },
        "4": {
            "time": 971,
            "sstate_checking": 602,
            "without_checking": 369
        },
        "5": {
            "time": 971,
            "sstate_checking": 605,
            "without_checking": 366
        }
    },
    "47": {
        "1": {
            "time": 996,
            "sstate_checking": 622,
            "without_checking": 374
        },
        "2": {
            "time": 995,
            "sstate_checking": 618,
            "without_checking": 377
        },
        "3": {
            "time": 994,
            "sstate_checking": 618,
            "without_checking": 376
        },
        "4": {
            "time": 993,
            "sstate_checking": 622,
            "without_checking": 371
        },
        "5": {
            "time": 975,
            "sstate_checking": 608,
            "without_checking": 367
        }
    },
    "48": {
        "1": {
            "time": 1014,
            "sstate_checking": 636,
            "without_checking": 378
        },
        "2": {
            "time": 1011,
            "sstate_checking": 620,
            "without_checking": 391
        },
        "3": {
            "time": 1003,
            "sstate_checking": 621,
            "without_checking": 382
        },
        "4": {
            "time": 1017,
            "sstate_checking": 636,
            "without_checking": 381
        },
        "5": {
            "time": 1022,
            "sstate_checking": 639,
            "without_checking": 383
        }
    },
    "49": {
        "1": {
            "time": 1095,
            "sstate_checking": 643,
            "without_checking": 452
        },
        "2": {
            "time": 1036,
            "sstate_checking": 648,
            "without_checking": 388
        },
        "3": {
            "time": 1036,
            "sstate_checking": 645,
            "without_checking": 391
        },
        "4": {
            "time": 1031,
            "sstate_checking": 634,
            "without_checking": 397
        },
        "5": {
            "time": 1029,
            "sstate_checking": 642,
            "without_checking": 387
        }
    },
    "50": {
        "1": {
            "time": 1058,
            "sstate_checking": 660,
            "without_checking": 398
        },
        "2": {
            "time": 1060,
            "sstate_checking": 661,
            "without_checking": 399
        },
        "3": {
            "time": 1070,
            "sstate_checking": 666,
            "without_checking": 404
        },
        "4": {
            "time": 1040,
            "sstate_checking": 648,
            "without_checking": 392
        },
        "5": {
            "time": 1062,
            "sstate_checking": 661,
            "without_checking": 401
        }
    },
    "51": {
        "1": {
            "time": 1083,
            "sstate_checking": 681,
            "without_checking": 402
        },
        "2": {
            "time": 1093,
            "sstate_checking": 682,
            "without_checking": 411
        },
        "3": {
            "time": 1074,
            "sstate_checking": 668,
            "without_checking": 406
        },
        "4": {
            "time": 1080,
            "sstate_checking": 673,
            "without_checking": 407
        },
        "5": {
            "time": 1082,
            "sstate_checking": 671,
            "without_checking": 411
        }
    },
    "52": {
        "1": {
            "time": 1111,
            "sstate_checking": 686,
            "without_checking": 425
        },
        "2": {
            "time": 1117,
            "sstate_checking": 694,
            "without_checking": 423
        },
        "3": {
            "time": 1130,
            "sstate_checking": 687,
            "without_checking": 443
        },
        "4": {
            "time": 1114,
            "sstate_checking": 697,
            "without_checking": 417
        },
        "5": {
            "time": 1097,
            "sstate_checking": 683,
            "without_checking": 414
        }
    },
    "53": {
        "1": {
            "time": 1152,
            "sstate_checking": 700,
            "without_checking": 452
        },
        "2": {
            "time": 1129,
            "sstate_checking": 698,
            "without_checking": 431
        },
        "3": {
            "time": 1124,
            "sstate_checking": 694,
            "without_checking": 430
        },
        "4": {
            "time": 1129,
            "sstate_checking": 699,
            "without_checking": 430
        },
        "5": {
            "time": 1119,
            "sstate_checking": 696,
            "without_checking": 423
        }
    }
}
```

Для удобства восприятия результатов были высчитаны средние значения для каждой метрики:
```json
{
    "2": {
        "avg_time": 263.2,
        "avg_sstate_checking": 34.0,
        "avg_without_checking": 229.2
    },
    "3": {
        "avg_time": 286.6,
        "avg_sstate_checking": 45.8,
        "avg_without_checking": 240.8
    },
    "4": {
        "avg_time": 306.2,
        "avg_sstate_checking": 58.2,
        "avg_without_checking": 248.0
    },
    "5": {
        "avg_time": 362.2,
        "avg_sstate_checking": 71.6,
        "avg_without_checking": 290.6
    },
    "6": {
        "avg_time": 331.0,
        "avg_sstate_checking": 83.8,
        "avg_without_checking": 247.2
    },
    "7": {
        "avg_time": 340.2,
        "avg_sstate_checking": 97.0,
        "avg_without_checking": 243.2
    },
    "8": {
        "avg_time": 356.2,
        "avg_sstate_checking": 111.0,
        "avg_without_checking": 245.2
    },
    "9": {
        "avg_time": 368.4,
        "avg_sstate_checking": 124.0,
        "avg_without_checking": 244.4
    },
    "10": {
        "avg_time": 383.0,
        "avg_sstate_checking": 135.4,
        "avg_without_checking": 247.6
    },
    "11": {
        "avg_time": 397.0,
        "avg_sstate_checking": 151.0,
        "avg_without_checking": 246.0
    },
    "12": {
        "avg_time": 410.0,
        "avg_sstate_checking": 164.0,
        "avg_without_checking": 246.0
    },
    "13": {
        "avg_time": 432.8,
        "avg_sstate_checking": 178.8,
        "avg_without_checking": 254.0
    },
    "14": {
        "avg_time": 448.6,
        "avg_sstate_checking": 193.4,
        "avg_without_checking": 255.2
    },
    "15": {
        "avg_time": 464.8,
        "avg_sstate_checking": 208.8,
        "avg_without_checking": 256.0
    },
    "16": {
        "avg_time": 498.6,
        "avg_sstate_checking": 221.2,
        "avg_without_checking": 277.4
    },
    "17": {
        "avg_time": 494.4,
        "avg_sstate_checking": 235.2,
        "avg_without_checking": 259.2
    },
    "18": {
        "avg_time": 513.2,
        "avg_sstate_checking": 248.8,
        "avg_without_checking": 264.4
    },
    "19": {
        "avg_time": 531.8,
        "avg_sstate_checking": 259.0,
        "avg_without_checking": 272.8
    },
    "20": {
        "avg_time": 545.2,
        "avg_sstate_checking": 275.4,
        "avg_without_checking": 269.8
    },
    "21": {
        "avg_time": 562.4,
        "avg_sstate_checking": 285.6,
        "avg_without_checking": 276.8
    },
    "22": {
        "avg_time": 586.8,
        "avg_sstate_checking": 305.2,
        "avg_without_checking": 281.6
    },
    "23": {
        "avg_time": 594.0,
        "avg_sstate_checking": 319.2,
        "avg_without_checking": 274.8
    },
    "24": {
        "avg_time": 603.4,
        "avg_sstate_checking": 329.2,
        "avg_without_checking": 274.2
    },
    "25": {
        "avg_time": 627.8,
        "avg_sstate_checking": 334.2,
        "avg_without_checking": 293.6
    },
    "26": {
        "avg_time": 830.4,
        "avg_sstate_checking": 359.2,
        "avg_without_checking": 471.2
    },
    "27": {
        "avg_time": 650.8,
        "avg_sstate_checking": 373.2,
        "avg_without_checking": 277.6
    },
    "28": {
        "avg_time": 661.8,
        "avg_sstate_checking": 377.6,
        "avg_without_checking": 284.2
    },
    "29": {
        "avg_time": 1027.4,
        "avg_sstate_checking": 396.6,
        "avg_without_checking": 630.8
    },
    "30": {
        "avg_time": 703.8,
        "avg_sstate_checking": 410.2,
        "avg_without_checking": 293.6
    },
    "31": {
        "avg_time": 748.0,
        "avg_sstate_checking": 422.4,
        "avg_without_checking": 325.6
    },
    "32": {
        "avg_time": 742.4,
        "avg_sstate_checking": 435.8,
        "avg_without_checking": 306.6
    },
    "33": {
        "avg_time": 767.4,
        "avg_sstate_checking": 457.8,
        "avg_without_checking": 309.6
    },
    "34": {
        "avg_time": 786.2,
        "avg_sstate_checking": 461.8,
        "avg_without_checking": 324.4
    },
    "35": {
        "avg_time": 801.2,
        "avg_sstate_checking": 474.6,
        "avg_without_checking": 326.6
    },
    "36": {
        "avg_time": 813.8,
        "avg_sstate_checking": 486.8,
        "avg_without_checking": 327.0
    },
    "37": {
        "avg_time": 832.8,
        "avg_sstate_checking": 498.8,
        "avg_without_checking": 334.0
    },
    "38": {
        "avg_time": 848.0,
        "avg_sstate_checking": 515.0,
        "avg_without_checking": 333.0
    },
    "39": {
        "avg_time": 866.2,
        "avg_sstate_checking": 533.8,
        "avg_without_checking": 332.4
    },
    "40": {
        "avg_time": 889.4,
        "avg_sstate_checking": 541.2,
        "avg_without_checking": 348.2
    },
    "41": {
        "avg_time": 895.4,
        "avg_sstate_checking": 549.6,
        "avg_without_checking": 345.8
    },
    "42": {
        "avg_time": 912.4,
        "avg_sstate_checking": 561.8,
        "avg_without_checking": 350.6
    },
    "43": {
        "avg_time": 932.8,
        "avg_sstate_checking": 579.2,
        "avg_without_checking": 353.6
    },
    "44": {
        "avg_time": 954.8,
        "avg_sstate_checking": 591.2,
        "avg_without_checking": 363.6
    },
    "45": {
        "avg_time": 974.4,
        "avg_sstate_checking": 607.0,
        "avg_without_checking": 367.4
    },
    "46": {
        "avg_time": 972.6,
        "avg_sstate_checking": 604.2,
        "avg_without_checking": 368.4
    },
    "47": {
        "avg_time": 990.6,
        "avg_sstate_checking": 617.6,
        "avg_without_checking": 373.0
    },
    "48": {
        "avg_time": 1013.4,
        "avg_sstate_checking": 630.4,
        "avg_without_checking": 383.0
    },
    "49": {
        "avg_time": 1045.4,
        "avg_sstate_checking": 642.4,
        "avg_without_checking": 403.0
    },
    "50": {
        "avg_time": 1058.0,
        "avg_sstate_checking": 659.2,
        "avg_without_checking": 398.8
    },
    "51": {
        "avg_time": 1082.4,
        "avg_sstate_checking": 675.0,
        "avg_without_checking": 407.4
    },
    "52": {
        "avg_time": 1113.8,
        "avg_sstate_checking": 689.4,
        "avg_without_checking": 424.4
    },
    "53": {
        "avg_time": 1130.6,
        "avg_sstate_checking": 697.4,
        "avg_without_checking": 433.2
    }
}
```
