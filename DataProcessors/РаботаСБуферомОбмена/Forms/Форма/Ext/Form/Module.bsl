﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ЗаполнитьФорматыБуфераСервер();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ЗаполнитьСтандратныеФорматыБуфера();
	
КонецПроцедуры

&НаКлиенте
Асинх Процедура ПриВставкеИзБуфераОбмена(Значение, СтандартнаяОбработка)
	
	//Если установить Ложь, то глобальное событие вызываться не будет
	//НО, в Асинх методах такое не работает. Поэтому надо сначала убрать Асинх
	//СтандартнаяОбработка = Ложь;

	Если ТипЗнч(Значение) = Тип("Массив") Тогда
		Коллекция = Значение;
	Иначе
		Коллекция = Новый Массив;
		Коллекция.Добавить(Значение);
	КонецЕсли;
	
	Для Каждого Элемент Из Коллекция Цикл
		
		ТипЭлемента = ТипЗнч(Элемент);
		
		НоваяСтрока = ПриВставкеИзБуфераОбменаДанные.Добавить();
		НоваяСтрока.Тип = ТипЭлемента;
		
		Если ТипЭлемента = Тип("Картинка") Тогда
			НоваяСтрока.АдресКартинки = ПоместитьВоВременноеХранилище(Элемент, УникальныйИдентификатор);
		ИначеЕсли ТипЭлемента = Тип("СсылкаНаФайл") Тогда
			НоваяСтрока.ПолноеИмяФайла = Элемент.Файл.ПолноеИмя;
			НоваяСтрока.СодержимоеФайла = Ждать Элемент.ПолучитьКакСтрокуАсинх();
			НоваяСтрока.ДвоичныеДанные = ПолучитьHexСтрокуИзДвоичныхДанных(
				Ждать Элемент.ПолучитьКакДвоичныеДанныеАсинх());
		КонецЕсли;	
		
	КонецЦикла;
	
	ПриВставкеИзБуфераОбменаДанныеПриАктивизацииСтроки();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыПриВставкеИзБуфераОбменаДанные

&НаКлиенте
Процедура ПриВставкеИзБуфераОбменаДанныеПриАктивизацииСтроки(Элемент = Неопределено)
	
	ТекущиеДанные = Элементы.ПриВставкеИзБуфераОбменаДанные.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ЕстьДвоичныеДанные = ЗначениеЗаполнено(ТекущиеДанные.ДвоичныеДанные);
	ЕстьКартинка = ЗначениеЗаполнено(ТекущиеДанные.АдресКартинки);
	ЕстьТекст = ЗначениеЗаполнено(ТекущиеДанные.СодержимоеФайла);
	
	Элементы.ПриВставкеИзБуфераОбменаСодержимоеСтраницаКартинка.Видимость = ЕстьКартинка;
	Элементы.ПриВставкеИзБуфераОбменаСодержимоеСтраницаФайлТекст.Видимость = ЕстьТекст;
    Элементы.ПриВставкеИзБуфераОбменаСодержимоеСтраницаФайлДвоичныеДанные.Видимость = ЕстьДвоичныеДанные;
    
КонецПроцедуры
	
#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Асинх Процедура Команда_СкопироватьВБуферОбмена(Команда)
	
	ТекущаяСтраница = Элементы.СтраницыСредстваБуфераОбмена.ТекущаяСтраница;
	Если ТекущаяСтраница = Элементы.СтраницаСредстваБуфераОбменаТекст Тогда
		Ждать СкопироватьТекстВБуферОбмена(СредстваБуфераОбменаТекст);
	ИначеЕсли ТекущаяСтраница = Элементы.СтраницаСредстваБуфераОбменаHTML Тогда
		Ждать СкопироватьHTMLВБуферОбмена(СредстваБуфераОбменаHTMLТекст);
	ИначеЕсли ТекущаяСтраница = Элементы.СтраницаСредстваБуфераОбменаКартинка Тогда
		Картинка = ПолучитьИзВременногоХранилища(СредстваБуфераОбменаКартинкаАдрес);
		Ждать СкопироватьКартинкуВБуферОбмена(Картинка);
	ИначеЕсли ТекущаяСтраница = Элементы.СтраницаСредстваБуфераОбменаТаблица Тогда
		Ждать СкопироватьТаблицуФормыВБуферОбмена(СредстваБуфераОбменаТаблицаФормы);
	КонецЕсли;
	
	
КонецПроцедуры

&НаКлиенте
Асинх Процедура Команда_ВставитьИзБуфераОбмена(Команда)
	
	ТекущаяСтраница = Элементы.СтраницыСредстваБуфераОбмена.ТекущаяСтраница;
	Если ТекущаяСтраница = Элементы.СтраницаСредстваБуфераОбменаТекст Тогда
		СредстваБуфераОбменаТекст = Ждать ТекстИзБуфераОбмена();
	ИначеЕсли ТекущаяСтраница = Элементы.СтраницаСредстваБуфераОбменаHTML Тогда
		СредстваБуфераОбменаHTMLТекст = Ждать HTMLИзБуфераОбмена();
	ИначеЕсли ТекущаяСтраница = Элементы.СтраницаСредстваБуфераОбменаКартинка Тогда
		КартинкаБуфера = Ждать КартинкаИзБуфераОбмена();
		СредстваБуфераОбменаКартинкаАдрес = ПоместитьВоВременноеХранилище(КартинкаБуфера, УникальныйИдентификатор);
	ИначеЕсли ТекущаяСтраница = Элементы.СтраницаСредстваБуфераОбменаТаблица Тогда
		Ждать ВставитьСтрокиВТаблицуФормыИзБуфера(СредстваБуфераОбменаТаблицаФормы);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Асинх Процедура Команда_ПрочитатьБуферОбмена(Команда)
	
	Для Каждого ТекущаяСтрока Из ФорматыБуфера Цикл
		
		ПроверяемыйТип = ?(ТекущаяСтрока.Стандратный, СтандартныйФорматДанныхБуфераОбмена[ТекущаяСтрока.Ключ], ТекущаяСтрока.Ключ);
		
		ТекущаяСтрока.СодержитсяВБуфере = Ждать СредстваБуфераОбмена.СодержитДанныеАсинх(ПроверяемыйТип);
		
		Если ТекущаяСтрока.СодержитсяВБуфере Тогда
			Содержимое = Ждать СредстваБуфераОбмена.ПолучитьДанныеАсинх(ПроверяемыйТип);
			Если ТипЗнч(Содержимое) = Тип("ДвоичныеДанные") Тогда
				Попытка
					Содержимое = ПолучитьСтрокуИзДвоичныхДанных(Содержимое);
				Исключение
				    Содержимое = ПолучитьHexСтрокуИзДвоичныхДанных(Содержимое);
				КонецПопытки;
			КонецЕсли;
			ТекущаяСтрока.Содержимое = Содержимое;
		КонецЕсли;
			
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура Команда_ОчиститьТаблицуФормы(Команда)
	
	ТекущаяСтраница = Элементы.Страницы.ТекущаяСтраница;
	Если ТекущаяСтраница = Элементы.СтраницаСредстваБуфераОбмена Тогда
		ТаблицаФормы = СредстваБуфераОбменаТаблицаФормы;
	ИначеЕсли ТекущаяСтраница = Элементы.СтраницаПриВставкеИзБуфераОбмена Тогда
		ТаблицаФормы = ПриВставкеИзБуфераОбменаДанные;
	Иначе
		Возврат;
	КонецЕсли;
	
	ТаблицаФормы.Очистить();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область Инициализация

// Заполняет MIME форматы буфера из макета
&НаСервере
Процедура ЗаполнитьФорматыБуфераСервер()
	
	МакетФорматов   = РеквизитФормыВЗначение("Объект").ПолучитьМакет("ФорматыБуфера");
	КоличествоСтрок = МакетФорматов.КоличествоСтрок();
	Для НомерСтроки = 1 По КоличествоСтрок Цикл
		НоваяСтрока = ФорматыБуфера.Добавить();
		НоваяСтрока.Ключ = МакетФорматов.ПолучитьСтроку(НомерСтроки);
	КонецЦикла;
	
	Элементы.СодержащиесяТипыБуфера.ОтборСтрок = Новый ФиксированнаяСтруктура("СодержитсяВБуфере", Истина);
	
КонецПроцедуры

// Заполняет стандратные форматы буфера
&НаКлиенте
Процедура ЗаполнитьСтандратныеФорматыБуфера()
	
	Для Каждого Формат Из СтандартныйФорматДанныхБуфераОбмена Цикл
		
		ТекущаяСтрока = ФорматыБуфера.Вставить(0);
		ТекущаяСтрока.Стандратный = Истина;
		ТекущаяСтрока.Ключ = Строка(Формат);
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область ПримерыРаботыСБуфером

// Копирует переданный текст в буфер обмена
//
// Параметры:
//  Текст - Строка 
// 
// Возвращаемое значение:
//  Булево - Признак успеха
//
&НаКлиенте
Асинх Функция СкопироватьТекстВБуферОбмена(Текст)
	
	ФорматДанных = СтандартныйФорматДанныхБуфераОбмена.Текст;
	Возврат ПоместитьВБуфераОбмена(Новый ЭлементБуфераОбмена(ФорматДанных, Текст));
	
КонецФункции

// Возвращает текст из буфера обмена
// 
// Возвращаемое значение:
// 	Строка
//
&НаКлиенте
Асинх Функция ТекстИзБуфераОбмена()
	
	Возврат СодержимоеБуфераОбмена(СтандартныйФорматДанныхБуфераОбмена.Текст);
	
КонецФункции

// Копирует переданный текст HTML в буфер обмена
//
// Параметры:
//  Текст - Строка
// 
// Возвращаемое значение:
//  Булево - Признак успеха
//
&НаКлиенте
Асинх Функция СкопироватьHTMLВБуферОбмена(Текст)
	
	ФорматДанных = СтандартныйФорматДанныхБуфераОбмена.HTML;
	Возврат ПоместитьВБуфераОбмена(Новый ЭлементБуфераОбмена(ФорматДанных, Текст));
	
КонецФункции

// Возвращает текст HTML из буфера обмена
// 
// Возвращаемое значение:
// 	Строка
//
&НаКлиенте
Асинх Функция HTMLИзБуфераОбмена()
	
	Возврат СодержимоеБуфераОбмена(СтандартныйФорматДанныхБуфераОбмена.HTML);
	
КонецФункции

// Копирует переданную картинку в буфер обмена
//
// Параметры:
//  Картинка - Картинка
// 
// Возвращаемое значение:
//  Булево - Признак успеха
//
&НаКлиенте
Асинх Функция СкопироватьКартинкуВБуферОбмена(Картинка)
	
	ФорматДанных = СтандартныйФорматДанныхБуфераОбмена.Картинка;
	Возврат ПоместитьВБуфераОбмена(Новый ЭлементБуфераОбмена(ФорматДанных, Картинка));
	
КонецФункции

// Возвращает картинку из буфера обмена
// 
// Возвращаемое значение:
// 	Картинка
//
&НаКлиенте
Асинх Функция КартинкаИзБуфераОбмена()
	
	Возврат СодержимоеБуфераОбмена(СтандартныйФорматДанныхБуфераОбмена.Картинка);
	
КонецФункции

// Копирует переданную таблицу формы в буфер обмена в форматах Текст, HTML, XML
//
// Параметры:
//  ТаблицаФормы - ДанныеФормыКоллекция
// 
// Возвращаемое значение:
//  Булево - Признак успеха
//
&НаКлиенте
Асинх Функция СкопироватьТаблицуФормыВБуферОбмена(ТаблицаФормы)
	
	ПомещаемыеДанные = ПомещаемыеДанныеТаблицыФормы(ТаблицаФормы);
	
	ЭлементыБуфера = Новый Массив;
	
	ЭлементыБуфера.Добавить(Новый ЭлементБуфераОбмена(
		СтандартныйФорматДанныхБуфераОбмена.HTML, ПомещаемыеДанные.HTML));
	
	ЭлементыБуфера.Добавить(Новый ЭлементБуфераОбмена(
		СтандартныйФорматДанныхБуфераОбмена.Текст, ПомещаемыеДанные.Текст));
		
	ЭлементыБуфера.Добавить(Новый ЭлементБуфераОбмена(
		"text/xml", ПомещаемыеДанные.Таблица));
	
	Возврат ПоместитьВБуфераОбмена(ЭлементыБуфера);
	
КонецФункции

// Вставляет данные XML в таблицу формы
// 
// Возвращаемое значение:
// 	Булево - Признак успеха
//
&НаКлиенте
Асинх Функция ВставитьСтрокиВТаблицуФормыИзБуфера(ТаблицаФормы)
	
	ДанныеБуфера = Ждать СодержимоеБуфераОбмена("text/xml");
	Если ДанныеБуфера <> Неопределено Тогда
		ДанныеБуфера = СодержимоеXMLБуфераОбмена(ДанныеБуфера);
		Для Каждого ТекущаяСтрока Из ДанныеБуфера Цикл
			ЗаполнитьЗначенияСвойств(ТаблицаФормы.Добавить(), ТекущаяСтрока);
		КонецЦикла;
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции

// Возвращает структуру с подготовленными данными для помещения в буфер
//
// Параметры:
//  ТаблицаФормы - ДанныеФормыКоллекция
// 
// Возвращаемое значение:
//  Структура -:
//  *Текст - см. ТаблицаЗначенийВТекст
//  *HTML - см. ТаблицаЗначенийВHTML
//  *Таблица - см. ЗначениеВДвоичныеДанныеСXML
//
&НаСервереБезКонтекста
Функция ПомещаемыеДанныеТаблицыФормы(ТаблицаФормы)
	
	ТаблицаЗначений = ТаблицаФормы.Выгрузить();
	МассивДанных = ТаблицаЗначенийВМассив(ТаблицаЗначений);
	
	Результат = Новый Структура;
	Результат.Вставить("Текст", ТаблицаЗначенийВТекст(ТаблицаЗначений));
	Результат.Вставить("HTML", ТаблицаЗначенийВHTML(ТаблицаЗначений));
	Результат.Вставить("Таблица", ЗначениеВДвоичныеДанныеСXML(МассивДанных));
	
	Возврат Результат;

КонецФункции

#КонецОбласти

#Область МетодыРаботыСБуфером

// Возвращает содержимое буфера обмена
//
// Параметры:
//  ФорматДанных		 - СтандартныйФорматДанныхБуфераОбмена, Строка - Формат буфера
//  ЗначениеПоУмолчанию	 - Произвольный, Неопределено - Возвращается при отстутствии данных или доступа к буферу
// 
// Возвращаемое значение:
//  Произвольный 
//
&НаКлиенте
Асинх Функция СодержимоеБуфераОбмена(ФорматДанных, ЗначениеПоУмолчанию = Неопределено)
	
    Если СредстваБуфераОбмена.ИспользованиеДоступно() Тогда
        Если Ждать СредстваБуфераОбмена.СодержитДанныеАсинх(ФорматДанных) Тогда
            Возврат Ждать СредстваБуфераОбмена.ПолучитьДанныеАсинх(ФорматДанных);
        КонецЕсли;
    КонецЕсли;
	
    Возврат ЗначениеПоУмолчанию;
		
КонецФункции

// Помещает данные в буфера обмена
//
// Параметры:
//  Данные - ЭлементБуфераОбмена, Массив из ЭлементБуфераОбмена - Помещаемые данные
// 
// Возвращаемое значение:
//  Булево - Признак успеха
//
&НаКлиенте
Асинх Функция ПоместитьВБуфераОбмена(Данные)
	
    Если СредстваБуфераОбмена.ИспользованиеДоступно() Тогда
		
        Если ТипЗнч(Данные) = Тип("ЭлементБуфераОбмена") Тогда
            ПомещаемыеДанные = Новый Массив;
            ПомещаемыеДанные.Добавить(Данные);
        Иначе
            ПомещаемыеДанные = Данные;
        КонецЕсли;
		
        Для Каждого ТекущиеДанные Из ПомещаемыеДанные Цикл
			
            Если НЕ Ждать СредстваБуфераОбмена.ПоддерживаетсяФорматДанных(ТекущиеДанные.ФорматДанных) Тогда
                Возврат Ложь;
            КонецЕсли;
			
        КонецЦикла;
		
        Возврат Ждать СредстваБуфераОбмена.ПоместитьДанныеАсинх(ПомещаемыеДанные);
		
    КонецЕсли;
	
    Возврат Ложь;
		
КонецФункции
	
#КонецОбласти

#Область ПреобразованиеЗначений

// Возвращает текст HTML из Таблицы значений
//
// Параметры:
//  Значение - ТаблицаЗначений 
// 
// Возвращаемое значение:
//  Строка 
//
&НаСервереБезКонтекста
Функция ТаблицаЗначенийВHTML(Значение)
	
	ПотокТекста  = Новый ПотокВПамяти;
	ЗаписьТекста = Новый ЗаписьТекста(ПотокТекста);
	
	ЗаписьТекста.ЗаписатьСтроку("<table bgcolor='#E0FFFF' bordercolor='#006400' border=1><tr>");
	Для Каждого Колонка Из Значение.Колонки Цикл
		ЗаписьТекста.Записать(СтрШаблон("<th>%1</th>", Колонка.Имя));
	КонецЦикла;
	ЗаписьТекста.ЗаписатьСтроку("</tr>");
	
	Для Каждого Строка Из Значение Цикл
		ЗаписьТекста.ЗаписатьСтроку("<tr>");
		Для Каждого Колонка Из Значение.Колонки Цикл
			ЗаписьТекста.Записать(СтрШаблон("<td>%1</td>", Строка(Строка[Колонка.Имя])));			
		КонецЦикла;
		ЗаписьТекста.ЗаписатьСтроку("</tr>");
	КонецЦикла;
	
	ЗаписьТекста.ЗаписатьСтроку("</table>");
	ЗаписьТекста.Закрыть();
	
	Возврат ПолучитьСтрокуИзДвоичныхДанных(ПотокТекста.ЗакрытьИПолучитьДвоичныеДанные());
	
КонецФункции

// Возвращает строку из Таблицы значений
//
// Параметры:
//  Значение - ТаблицаЗначений 
// 
// Возвращаемое значение:
//  Строка 
//
&НаСервереБезКонтекста
Функция ТаблицаЗначенийВТекст(Значение)
	
	Разделитель  = Символы.Таб;
	ПотокТекста  = Новый ПотокВПамяти;
	ЗаписьТекста = Новый ЗаписьТекста(ПотокТекста);
	
	Для Каждого Колонка Из Значение.Колонки Цикл
		ЗаписьТекста.Записать(Колонка.Имя + Разделитель);			
	КонецЦикла;
	ЗаписьТекста.ЗаписатьСтроку("");
	
	Для Каждого Строка Из Значение Цикл
		Для Каждого Колонка Из Значение.Колонки Цикл
			ЗаписьТекста.Записать(Строка(Строка[Колонка.Имя]) + Разделитель);			
		КонецЦикла;
		ЗаписьТекста.ЗаписатьСтроку("");
	КонецЦикла;
	
	ЗаписьТекста.Закрыть();
	
	Возврат ПолучитьСтрокуИзДвоичныхДанных(ПотокТекста.ЗакрытьИПолучитьДвоичныеДанные());
	
КонецФункции

// Сериализует значение в XML и возвращает двоичные данные
//
// Параметры:
//  Значение - Произвольный 
// 
// Возвращаемое значение:
//  ДвоичныеДанные - содержит текст XML 
//
&НаСервереБезКонтекста
Функция ЗначениеВДвоичныеДанныеСXML(Значение)
	
	СтрокаXML = ЗначениеВСтрокуXML(Значение);
	Возврат ПолучитьДвоичныеДанныеИзСтроки(СтрокаXML);
	
КонецФункции

// Извлекает содержимое XML из буфера обмена
//
// Параметры:
//  ДвоичныеДанные - ДвоичныеДанные
// 
// Возвращаемое значение:
//  Произвольный 
//
&НаСервереБезКонтекста
Функция СодержимоеXMLБуфераОбмена(ДвоичныеДанные)

	СтрокаXML = ПолучитьСтрокуИзДвоичныхДанных(ДвоичныеДанные);
	Возврат ЗначениеИзСтрокиXML(СтрокаXML);
	
КонецФункции
	
#КонецОбласти

#Область БСП

// Преобразует (сериализует) любое значение в XML-строку.
// Преобразованы в могут быть только те объекты, для которых в синтакс-помощнике указано, что они сериализуются.
// См. также ЗначениеИзСтрокиXML.
//
// Параметры:
//  Значение - Произвольный - значение, которое необходимо сериализовать в XML-строку.
//
// Возвращаемое значение:
//  Строка - XML-строка.
//
&НаСервереБезКонтекста
Функция ЗначениеВСтрокуXML(Значение) Экспорт
	
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.УстановитьСтроку();
	СериализаторXDTO.ЗаписатьXML(ЗаписьXML, Значение, НазначениеТипаXML.Явное);
	
	Возврат ЗаписьXML.Закрыть();
	
КонецФункции

// Выполняет преобразование (десериализацию) XML-строки в значение.
// См. также ЗначениеВСтрокуXML.
//
// Параметры:
//  СтрокаXML - Строка - XML-строка, с сериализованным объектом..
//
// Возвращаемое значение:
//  Произвольный - значение, полученное из переданной XML-строки.
//
&НаСервереБезКонтекста
Функция ЗначениеИзСтрокиXML(СтрокаXML) Экспорт
	
	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.УстановитьСтроку(СтрокаXML);
	
	Возврат СериализаторXDTO.ПрочитатьXML(ЧтениеXML);
	
КонецФункции

// Преобразует таблицу значений в массив структур.
// Может использоваться для передачи на клиент данных в том случае, если таблица
// значений содержит только такие значения, которые могут
// быть переданы с сервера на клиент.
//
// Полученный массив содержит структуры, каждая из которых повторяет
// структуру колонок таблицы значений.
//
// Не рекомендуется использовать для преобразования таблиц значений
// с большим количеством строк.
//
// Параметры:
//  ТаблицаЗначений - ТаблицаЗначений - исходная таблица значений.
//
// Возвращаемое значение:
//  Массив - коллекция строк таблицы в виде структур.
//
&НаСервереБезКонтекста
Функция ТаблицаЗначенийВМассив(ТаблицаЗначений) Экспорт
	
	Массив = Новый Массив();
	СтруктураСтрокой = "";
	НужнаЗапятая = Ложь;
	Для Каждого Колонка Из ТаблицаЗначений.Колонки Цикл
		Если НужнаЗапятая Тогда
			СтруктураСтрокой = СтруктураСтрокой + ",";
		КонецЕсли;
		СтруктураСтрокой = СтруктураСтрокой + Колонка.Имя;
		НужнаЗапятая = Истина;
	КонецЦикла;
	Для Каждого Строка Из ТаблицаЗначений Цикл
		НоваяСтрока = Новый Структура(СтруктураСтрокой);
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Строка);
		Массив.Добавить(НоваяСтрока);
	КонецЦикла;
	Возврат Массив;

КонецФункции

#КонецОбласти

#КонецОбласти
