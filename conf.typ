/*
 * Примечания:
 * - Код разбит по модулям, каждый из которых объявляется и инициализируется
 *   в переменной modules. Методы именуются в змеином стиле, при этом
 *   приватные начинаются с подчёркивания.
 *
 *   В силу отсутствия адекватной реализации приватных методов в Typst
 *   приватность --- лишь условное соглашение: такие методы не предназначены
 *   для вызова извне, хотя фактически такая возможность имеется.
 *   Не делайте так!
 *
 * - Чтобы не засорять кодовую базу, строковые константы вынесены в
 *   переменную strings.
 */
#let strings = (
	title: (
		minobrnauki: "МИНОБРНАУКИ РОССИИ\nФедеральное государственное бюджетное образовательное учреждение\nвысшего образования\n",
		sgu: "«САРАТОВСКИЙ НАЦИОНАЛЬНЫЙ ИССЛЕДОВАТЕЛЬСКИЙ
ГОСУДАРСТВЕННЫЙ УНИВЕРСИТЕТ
ИМЕНИ Н. Г. ЧЕРНЫШЕВСКОГО»\n",
		city: "Саратов"
	),
	student: (
		male: "студента",
		female: "студентки",
		plural: "студентов",
	),
	specialities: (
		spec_kb: [10.05.01 --- Компьютерная безопасность],
		bac_ivt: [09.03.01 --- Информатика и вычислительная техника],
		bac_moais: [02.03.03 --- Математическое обеспечение и администрирование информационных систем],
		bac_fiit: [02.03.02 --- Фундаментальная информатика и информационные технологии],
		bac_pi: [09.03.04 --- Программная инженерия],
		mag_ivt: [09.04.01 --- Информатика и вычислительная техника],
		mag_moais: [02.04.03 --- Математическое обеспечение и администрирование информационных систем],
	),
	error: (
		no_sex: [*6.21 КоАП РФ*]
	)
)



#let get_student_word(sex) = {
	return strings.student.at(sex, default: strings.error.no_sex)
}

#let get_speciality(group) = {
	let specialities = (
		strings.specialities.bac_fiit,
		strings.specialities.bac_ivt,
		strings.specialities.spec_kb,
		strings.specialities.bac_moais,
		strings.specialities.bac_pi,
		[], // x6x
		strings.specialities.mag_ivt,
		strings.specialities.mag_moais,
		[], // x8x
	)
	if group.at(1) == "7" { // x7x
		if group.at(2) == "1" { // x71
			return specialities.at(6) // ивт
		} else if group.at(2) == "3" {	// x73
			return specialities.at(7) // моаис
		}
		return []
	}
	let id = int(group.at(1)) - 1;
	
	if id < 0 or id > 8 {
		return []
	}
	return specialities.at(id)
}

#let otchet_title(info) = {
		let author = info.at("author", default: (:))
		set align(center)
}


#let modules = (
	author_info: (
		get_author_sex:
			(author) => {
				return strings.student.at(author.at("sex"), default: strings.error.no_sex)
			},
		get_author_course:
			(author) => {
				return author.group.at(0)
			},
		get_author_group:
			(author) => {
				return author.group
			}
	),
	title: (
		/*
		 * Отвечает за вывод названия университета
		 * на титульном листе
		 */
		_header:
			() => {
				set align(center)
				set text(font: "Tempora")
				text(strings.title.minobrnauki)
				v(0.2em)
				text(weight: "bold", strings.title.sgu)
				set align(left)
			},

		/*
		 * Подпись "Проверено:" для титульного листа
		 */
		_signature:
			(post, name) => {
				grid(
					columns: (1fr,) * 3,
					align: (left, center, right),
					row-gutter: 5pt,
					post, block(inset: (y: 13pt), line(length: 3cm, stroke: .4pt)), name
				)
			},
		_get_author_string:
			(self, author) => {
				let sex = self.author_info.get_author_sex(author)
				let course = self.author_info.get_author_course(author)
				let group = self.author_info.get_author_group(author)
                if course.len() > 0 {
                    course = self.uitls.strglue(course, "курса")
                }
                if group.len() > 0 {
                    group = self.utils.strglue(group, "группа")
                }
				let result = self.utils.strglue(sex, course, group) + "\n"
                return result
			},
		_default_title:
			(self, type, info) => {
				let author = info.at("author", default: (:))
				set align(center)
				v(3cm)
				if type == "autoref" {
						info.title = [АВТОРЕФЕРАТ]
				}
				if type == "nir" {
						info.title = [ОТЧЁТ О НАУЧНО-ИССЛЕДОВАТЕЛЬСКОЙ РАБОТЕ]
				}
				text(weight: "bold", upper(info.at("title", default: [Тема работы])))
				let worktypes = (
						referat: [РЕФЕРАТ],
						coursework: [КУРСОВАЯ РАБОТА],
						diploma: [Выпускная квалификационная работа],
						autoref: [работа],
						nir: [работа],
						pract: [Отчёт о практике]
				)
				par(worktypes.at(type, default: []))
				v(1.5cm)
				set align(left)
				let author_string = get_student_word(author.at("sex"))
				author_string = author_string + " " + author.group.at(0) + " курса " + author.group + " группы\n"
				if author.faculty == [КНиИТ] {
					author_string = author_string + "направления " + get_speciality(author.group) + "\n"
				} else if author.at("speciality", default: []) != [] {
					author_string = author_string + "направления " + author.speciality + "\n"
				}

				text(author_string + "факультета " + author.faculty + "\n" + author.name)
				v(1fr)
				text("Проверено:\n")
				(self.title._signature)(info.inspector.degree, info.inspector.name)
			},
		make:
			(
				self,
				type: str,
				info: ()
			) => {
				set page(
					paper: "a4",
					margin: (
						top: 2cm,
						bottom: 2cm,
						left: 2.5cm,
						right: 1.5cm
					)
				)
				
				(self.title._header)()
				(self.title._default_title)(self, type, info)
				
				v(1fr)
				set align(center)
				text(strings.title.city + " " + str(datetime.today().year()))
			}
	),
	utils: (
		strglue: 
			(
				divider: " ",
				..strings
			) => {
				let result = str(strings[0])
				let i = 1
				while i < strings.len() {
					if(
						(type(strings[i]) != str)
						or
						((result.len() > 0) and (strings[i].len() > 0))
					) {
						result = result + " "
					}
					result = result = str(strings[i])
				}
			}
	)
)


#let make_toc(
	info: ()
) = {

	outline(indent: 2%, title: [Содержание])
	pagebreak(weak: true)
}

#let conf(
	title: none,
	info: (),
	type: "referat",
	settings: (),
	doc
) = {
	info.title = title
	settings.title_page = settings.at("title_page", default: (:))


	set text(
		size: 14pt
	)

	if settings.title_page.at("enabled", default: true) {
		(modules.title.make)(modules, type: type, info: info)
	}
	set align(left)

	set page(footer: context [
		#h(1fr)
		#counter(page).display(
			"1"
		)
	])
	
	
	let caps_headings = (
		[Содержание],
		[Введение],
		[Заключение],
		[Список использованных источников],
		[Определения, обозначения и сокращения],
		[Обозначения и сокращения]
	)
	show heading: it => {
		set text(size: 14pt)
		if it.depth == 1 {
				pagebreak(weak: true)
				v(4.3pt * (3 + 1 - 0.2))
		}
		if caps_headings.contains(it.body) {
			set align(center)
			counter(heading).update(i => i - 1)
			upper(it.body)
		} else {
			it
		}
		v(4.3pt * (0.4 + 0.2))
	}
	set heading(numbering: "1.1")
	set page(numbering: "1")
	// Отступ начала абазаца 1.25 см и выравнивание по ширине
	set par(
		justify: true
	)
	if settings.contents_page.enabled {
		make_toc(info: info)
	}
	set math.equation(numbering: "(1)", supplement: [])
	set figure(supplement: "Рис.")
	doc

	/*let count = authors.len()
	let ncols = calc.min(count, 3)
	grid(
		columns: (1fr,) * ncols,
		row-gutter: 24pt,
		..authors.map(author => [
			#author.name \
			#author.affiliation \
			#link("mailto:" + author.email)
		]),
	)

	par(justify: false)[
		*Abstract* \
		#abstract
	]*/
}


#let indent = 1cm
#let styled = [#set text(red)].func()
#let space = [ ].func()
#let sequence = [].func()

#let turn-on-first-line-indentation(
	doc,
	last-is-heading: false, // space and parbreak are ignored
	indent-already-added: false,
) = {
	for (i, elem) in doc.children.enumerate() {
		let element = elem.func()
		if element == text {
			let previous-elem = doc.children.at(i - 1)
			if i == 0 or last-is-heading or previous-elem.func() == parbreak {
				if not indent-already-added {
					indent-already-added = true
					h(indent)
				}
			}
			elem
		} else if element == heading {
			indent-already-added = false
			last-is-heading = true
			elem
		} else if element == space {
			elem
		} else if element == parbreak {
			indent-already-added = false
			elem
		} else if element == sequence {
			turn-on-first-line-indentation(
				elem,
				last-is-heading: last-is-heading,
				indent-already-added: indent-already-added,
			)
		} else if element == styled {
			styled(turn-on-first-line-indentation(
				elem.child,
				last-is-heading: last-is-heading,
				indent-already-added: indent-already-added,
			), elem.styles)
		} else {
			indent-already-added = false
			last-is-heading = false
			elem
		}
	}
}
