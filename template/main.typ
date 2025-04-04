#import "@local/sgu-template:0.0.1": conf
#show: conf.with(
  title: [Тема работы],
  type: "referat",
  info: (
    author: (
      name: [Григорьева Данилы Евгеньевича],
      faculty: [КНиИТ],
      group: "151",
      sex: "male",
    ),
    inspector: (
      degree: "доцент, к. ф.-м. н.",
      name: "С. В. Миронов",
    ),
  ),
  settings: (
    title_page: (
      enabled: true,
    ),
    contents_page: (
      enabled: true,
    ),
  ),
)
