package v8runner

import (
	"fmt"

	"./v8dumpMode"
	"./v8tools"
	log "github.com/sirupsen/logrus"
)

// Выгрузка конфигурации в файлы
//
// Параметры:
//   КаталогВыгрузки    - Строка - Путь к каталогу,  в который будет выгружена конфигурация;
//   ФорматВыгрузки     - РежимВыгрузкиКонфигурации - По умолчанию выгрузка производится в иерархическом формате:
//   ТолькоИзмененные   - Булево - указывает, что выгрузка будет обновлена (будут выгружены только файлы, версии которых отличаются от ранее выгруженных).
//                                 Файл версий (ConfigDumpInfo.xml) будет получен из текущего каталога выгрузки.
//	                               По завершении выгрузки файл версий обновляется
//   ПутьКФайлуИзменений - Строка - Указывает путь к файлу,в который будут выведены изменения текущей конфигурации. Изменения вычисляются относительно файла версий в текущем каталоге выгрузки.
//   ПутьКФайлуВерсийДляСравнения - Строка - Указывает путь к файлу, который будет использован для сравнения изменений.
//
//   Для того чтобы работали функции 8.3.10. необходимо явно указать версию
func (conf *Конфигуратор) ВыгрузитьКонфигурациюСРежимомВыгрузки(dir string, mode string) error {
	return conf.dumpConfigToFiles(dir, mode, false, "", "")
}

func (conf *Конфигуратор) ВыгрузитьКонфигурациюПоУмолчанию(dir string) error {
	return conf.dumpConfigToFiles(dir, РежимВыгрузкиКонфигурации.СтандартныйРежим(), false, "", "")
}

func (conf *Конфигуратор) ВыгрузитьКонфигурацию(КаталогВыгрузки string, ФорматВыгрузки string, ТолькоИзмененные bool, ПутьКФайлуИзменений string, ПутьКФайлуВерсийДляСравнения string) error {
	return conf.dumpConfigToFiles(КаталогВыгрузки, ФорматВыгрузки, ТолькоИзмененные, ПутьКФайлуИзменений, ПутьКФайлуВерсийДляСравнения)
}

// Выгрузка изменений в файлах конфигурации в файл
//
// Параметры:
//   КаталогВыгрузки 	- Строка - Путь к каталогу, в который была выгружена конфигурация;
//   ПутьКФайлуИзменений - Строка - Указывает путь к файлу,в который будут выведены изменения текущей конфигурации. Изменения вычисляются относительно файла версий в текущем каталоге выгрузки.
//   ПутьКФайлуВерсийДляСравнения - Строка - Указывает путь к файлу, который будет использован для сравнения изменений.
//   ФорматВыгрузки 	- РежимВыгрузкиКонфигурации - По умолчанию выгрузка производится в иерархическом формате.
//
//   Для того чтобы работали функции 8.3.10. необходимо явно указать версию
func (conf *Конфигуратор) ВыгрузитьИзмененияКонфигурацииВФайл(КаталогВыгрузки string, ФорматВыгрузки string, ПутьКФайлуИзменений string, ПутьКФайлуВерсийДляСравнения string) error {
	return conf.dumpConfigToFiles(КаталогВыгрузки, ФорматВыгрузки, true, ПутьКФайлуИзменений, ПутьКФайлуВерсийДляСравнения)
}

func (conf *Конфигуратор) dumpConfigToFiles(dir string, mode string, ch bool, pChFile string, pVersionFile string) error {

	var c = conf.СтандартныеПараметрыЗапускаКонфигуратора()

	c = append(c, fmt.Sprintf("/DumpConfigToFiles %s", dir))
	if ok, _ := РежимВыгрузкиКонфигурации.РежимДоступен(mode); ok {
		c = append(c, fmt.Sprintf("-format %s", mode))
	}

	if ch {
		//Если ПроверитьВозможностьОбновленияФайловВыгрузки(КаталогВыгрузки, ПутьКФайлуВерсийДляСравнения, ФорматВыгрузки) Тогда
		c = append(c, "-update", "-force")
		if v8tools.ЗначениеЗаполнено(pChFile) {
			c = append(c, fmt.Sprintf("-getChanges %s", pChFile))
		}
		if v8tools.ЗначениеЗаполнено(pChFile) {
			c = append(c, fmt.Sprintf("-configDumpInfoForChanges %s", pVersionFile))
		}
	}

	log.Debugf("Параметры запуска: %s", c)

	err := conf.ВыполнитьКоманду(c)

	return err
}
