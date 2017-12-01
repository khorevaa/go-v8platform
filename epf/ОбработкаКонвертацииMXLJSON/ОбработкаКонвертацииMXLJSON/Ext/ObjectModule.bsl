﻿Процедура СконвертироватьВJSON()
	
	//ПараметрЗапуска1 = "/tmp/2xqb2nhv.8wr.mxl;/media/khorevaa/764B7AA318E25C28/os-projects/os/v8storage/tests/fixtures/report.json";
	
	МассивПараметров = СтрРазделить(ПараметрЗапуска,";");
	
	Если НЕ МассивПараметров.Количество() = 2 Тогда
		ЗавершитьРаботуСистемы(Ложь,Ложь);
	КонецЕсли;
	
	
	ИмяВходногоФайла = МассивПараметров[0];
	ИмяИсходящегоФайла = МассивПараметров[1];
	
	МассивИменВерсии = Новый Массив;
	МассивИменВерсии.Добавить(НРег("Версия:"));
	МассивИменВерсии.Добавить(НРег("Version:"));
	ТабДок = Новый ТабличныйДокумент;
	ТабДок.Прочитать(ИмяВходногоФайла);
	Высота = ТабДок.ВысотаТаблицы;
	Ширина = ТабДок.ШиринаТаблицы; // всегда 9
	
	//Первая версия начинается с 5 строчки
	КолонкаКлюча = 1;
	КолонкаЗначенияКлюча = 2;
	
	МассивАвторов = Новый Массив;
	МассивВерсий = Новый Массив;
	
	НачальнаяПозиция = 4;
	
	Для НачальнаяПозиция = НачальнаяПозиция + 1 По Высота Цикл
		
		ТекстОбластиВерсия = ТабДок.Область(НачальнаяПозиция,КолонкаКлюча,НачальнаяПозиция,КолонкаКлюча).Текст;
		Если Не МассивИменВерсии.Найти(НРег(ТекстОбластиВерсия)) = Неопределено Тогда
			
			НачальнаяПозицияВерсии = НачальнаяПозиция; 
			
			НомерВерсии = ТабДок.Область(НачальнаяПозицияВерсии,КолонкаЗначенияКлюча,НачальнаяПозицияВерсии,КолонкаЗначенияКлюча).Текст;
			АвторВерсии = ПолучитьАвтора(ТабДок, НачальнаяПозицияВерсии);
			ДатаВерсии = ПолучитьДатуВремяВерсии(ТабДок, НачальнаяПозицияВерсии);
			КомментарийВерсии = ПолучитьКомментарийВерсии(ТабДок, НачальнаяПозицияВерсии);
			
			СтруктураВерсии = Новый Структура;
			СтруктураВерсии.Вставить("Номер", НомерВерсии);
			СтруктураВерсии.Вставить("Автор", АвторВерсии);
			СтруктураВерсии.Вставить("Дата", ДатаВерсии);
			СтруктураВерсии.Вставить("Комментарий", КомментарийВерсии);
			
			
			
			МассивВерсий.Добавить(СтруктураВерсии);
			Если МассивАвторов.Найти(АвторВерсии) = Неопределено Тогда
				МассивАвторов.Добавить(АвторВерсии);
			КонецЕсли;
		КонецЕсли;
		
		
	КонецЦикла;
	
	
	Структура = Новый Структура;
	Структура.Вставить("Версии", МассивВерсий);	
	Структура.Вставить("Авторы", МассивАвторов);	
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.ОткрытьФайл(ИмяИсходящегоФайла);
	ЗаписатьJSON(ЗаписьJSON, Структура);
		
	ЗаписьJSON.Закрыть();
	
	//Сообщить(СтрШаблон("Количество версий: %1",МассивВерсий.Количество()));
	ЗавершитьРаботуСистемы(Ложь,Ложь);
	
КонецПроцедуры

Функция ПолучитьАвтора(ТабДок, НачальнаяПозицияВерсии)

	Возврат ТабДок.Область(НачальнаяПозицияВерсии+1,2,НачальнаяПозицияВерсии+1,2).Текст;
	
КонецФункции

Функция ПолучитьДатуВремяВерсии(ТабДок, НачальнаяПозицияВерсии)

	Дата = ТабДок.Область(НачальнаяПозицияВерсии+2,2,НачальнаяПозицияВерсии+2,2).Текст;
	Время = ТабДок.Область(НачальнаяПозицияВерсии+3,2,НачальнаяПозицияВерсии+3,2).Текст;
	
	Возврат СтрШаблон("%1 %2", Дата, Время);
	
КонецФункции

Функция ПолучитьКомментарийВерсии(ТабДок, НачальнаяПозицияВерсии)

	Возврат ТабДок.Область(НачальнаяПозицияВерсии+4,2,НачальнаяПозицияВерсии+4,2).Текст;
	
КонецФункции


СконвертироватьВJSON();