;;;********************************************************************
;;;  Экспертная система предварительной диагностики заболеваний собак
;;;  по клиническим симптомам (CLIPS, прямой вывод / forward chaining)
;;;
;;;  Запуск в CLIPS:
;;;    (clear)
;;;    (load "clips-ES/dog_expert.clp")
;;;    (reset)
;;;    (run)
;;;********************************************************************

;;;********************************************************************
;;;  Вспомогательные функции диалога с пользователем
;;;********************************************************************

;;; Функция ask-question выводит вопрос ?question и запрашивает у
;;; пользователя ответ из списка допустимых значений $?allowed-values.
;;; При получении EOF корректно останавливает вывод.
(deffunction ask-question (?question $?allowed-values)
   (printout t ?question)
   (bind ?answer (read))
   (if (eq ?answer EOF)
       then
       (printout t crlf "Ввод прерван." crlf)
       (halt)
       (return EOF))
   (if (lexemep ?answer)
       then (bind ?answer (lowcase ?answer)))
   (while (not (member$ ?answer ?allowed-values)) do
      (printout t "Пожалуйста, введите 'да.' или 'нет.' (с точкой в конце)." crlf)
      (printout t ?question)
      (bind ?answer (read))
      (if (eq ?answer EOF)
          then
          (printout t crlf "Ввод прерван." crlf)
          (halt)
          (return EOF))
      (if (lexemep ?answer)
          then (bind ?answer (lowcase ?answer))))
   ?answer)

;;; Функция yes-or-no-p задаёт пользователю вопрос ?question и
;;; возвращает TRUE при ответе да., FALSE при ответе нет. или EOF.
(deffunction yes-or-no-p (?question)
   (bind ?response (ask-question ?question да. нет.))
   (if (eq ?response EOF)
       then (return EOF))
   (if (eq ?response да.)
       then TRUE
       else FALSE))

;;; Функция ask-symptom задаёт вопрос о симптоме ?symptom и добавляет
;;; в рабочую память упорядоченный факт (symptom ?symptom yes|no).
(deffunction ask-symptom (?symptom ?question)
   (bind ?answer (yes-or-no-p ?question))
   (if (eq ?answer TRUE)
       then (assert (symptom ?symptom yes))
       else (if (eq ?answer FALSE)
                then (assert (symptom ?symptom no)))))

;;;********************************************************************
;;;  База фактов: клинические рекомендации (AAHA Triage, зоонозность,
;;;  рекомендуемая ветеринарная диагностика)
;;;********************************************************************

(deffacts clinical-recommendations
   (recommendation
      "Острое расширение и заворот желудка (GDV)"
      "КРАСНЫЙ (Экстренно! Немедленно везите собаку в клинику — состояние угрожает жизни в течение часов)"
      none
      "рентгенография брюшной полости, оценка шока и электролитов, экстренная декомпрессия и хирургическое лечение")

   (recommendation
      "Парвовирусный энтерит"
      "КРАСНЫЙ (Экстренно! Немедленная госпитализация, инфузионная терапия и строгая изоляция от других собак)"
      none
      "экспресс-тест ИФА (ELISA) фекалий на антиген CPV / ПЦР, ОАК (лейкопения), биохимия крови")

   (recommendation
      "Острый панкреатит"
      "ЖЁЛТЫЙ / КРАСНЫЙ (Срочный визит в день обращения; при сильном угнетении или обезвоживании — экстренно)"
      none
      "тест на специфическую панкреатическую липазу собак (cPL), УЗИ брюшной полости, ОАК и биохимия крови")

   (recommendation
      "Лямблиоз"
      "ЖЁЛТЫЙ (Визит к врачу в течение 1-2 дней или быстрее при нарастающем обезвоживании)"
      "возможен низкий риск передачи человеку — соблюдайте строгую гигиену при уборке фекалий"
      "флотация кала с сульфатом цинка, ИФА-тест фекалий на антиген Giardia")

   (recommendation
      "Гельминтоз ЖКТ"
      "ЗЕЛЁНЫЙ (Плановый приём; для щенков и при выраженной слабости — в ближайшее время)"
      "отдельные виды гельминтов (например, Toxocara canis) опасны для человека — мойте руки и проводите дегельминтизацию по схеме врача"
      "центрифужная флотация кала и подбор антигельминтного препарата")

   (recommendation
      "Пиометра (гнойное воспаление матки)"
      "КРАСНЫЙ (Экстренно! Риск разрыва матки и сепсиса, немедленно обратитесь в клинику)"
      none
      "УЗИ брюшной полости, ОАК и биохимия крови; подготовка к экстренной операции")

   (recommendation
      "Бешенство"
      "КРАСНЫЙ (КРИТИЧЕСКАЯ ОПАСНОСТЬ! Изолируйте животное без прямого контакта и немедленно свяжитесь с государственной ветслужбой)"
      "СМЕРТЕЛЬНО ОПАСНЫЙ ЗООНОЗ! При укусе, оцарапывании или ослюнении немедленно обратитесь в травмпункт для экстренной профилактики"
      "карантин и диагностика строго под контролем государственной ветеринарной службы")

   (recommendation
      "Чума плотоядных"
      "КРАСНЫЙ (Экстренно! Высокая летальность и заразность для других собак — требуется изоляция и интенсивная терапия)"
      none
      "ОТ-ПЦР (RT-PCR) смывов или крови на вирус чумы плотоядных, ОАК, рентген грудной клетки")

   (recommendation
      "Лептоспироз"
      "КРАСНЫЙ (Экстренно! Риск острой почечной и печёночной недостаточности)"
      "ОПАСНЫЙ ЗООНОЗ! Возбудитель выделяется с мочой — используйте перчатки и предупредите персонал клиники заранее"
      "ПЦР крови и мочи, серологический тест MAT/ИФА, ОАК и биохимия крови (почечный и печёночный профили)")

   (recommendation
      "Бабезиоз (пироплазмоз)"
      "КРАСНЫЙ (Экстренно! Требуется специфическая терапия и контроль анемии/почек в ближайшие часы)"
      none
      "микроскопия мазка крови на Babesia, ПЦР, ОАК и биохимия крови")

   (recommendation
      "Эрлихиоз"
      "ЖЁЛТЫЙ (Осмотр в день обращения; при кровотечениях или резкой слабости — экстренно)"
      none
      "ИФА экспресс-тест на антитела к Ehrlichia / ПЦР, ОАК (контроль тромбоцитов), биохимия крови")

   (recommendation
      "Инфекционный трахеобронхит (вольерный кашель)"
      "ЖЁЛТЫЙ / ЗЕЛЁНЫЙ (Скорый осмотр с изоляцией от других собак; при одышке или отказе от корма — экстренно)"
      none
      "осмотр и аускультация, при затяжном течении — рентген грудной клетки и респираторная ПЦР-панель")

   (recommendation
      "Дирофиляриоз (сердечный гельминт)"
      "ЖЁЛТЫЙ (Визит в ближайшие 1-2 дня; при обмороках или тяжёлой одышке в покое — экстренно)"
      none
      "тест на антиген Dirofilaria immitis, тест Кнотта на микрофилярии, ЭхоКГ и рентген грудной клетки")

   (recommendation
      "Острый бактериальный цистит"
      "ЖЁЛТЫЙ (Визит в день обращения; при полной задержке мочи — КРАСНЫЙ, экстренно)"
      none
      "общий анализ мочи (цистоцентез), бактериологический посев мочи с чувствительностью, УЗИ мочевого пузыря")

   (recommendation
      "Сахарный диабет"
      "ЖЁЛТЫЙ (Срочный осмотр; при рвоте, угнетении или запахе ацетона — экстренно из-за риска кетоацидоза)"
      none
      "глюкометрия, фруктозамин, общий анализ мочи, ОАК и биохимия крови")

   (recommendation
      "Наружный отит"
      "ЖЁЛТЫЙ / ЗЕЛЁНЫЙ (Визит в ближайшие дни для предотвращения осложнений на среднее ухо)"
      none
      "отоскопия слухового прохода и цитология мазка из уха")

   (recommendation
      "Саркоптоз (зудневая чесотка)"
      "ЖЁЛТЫЙ (Скорый приём и изоляция от других животных)"
      "возможен псевдосаркоптоз (зудящая сыпь) у человека при контакте — используйте перчатки и продезинфицируйте подстилки"
      "поверхностные соскобы кожи (края ушей, локти), оценка ушного рефлекса, назначение акарицидной терапии")

   (recommendation
      "Атопический дерматит"
      "ЗЕЛЁНЫЙ (Плановый приём у ветеринарного дерматолога)"
      none
      "исключение паразитов и вторичных инфекций (соскобы, цитология), элиминационная диета 8-12 недель")

   (recommendation
      "Демодекоз"
      "ЗЕЛЁНЫЙ / ЖЁЛТЫЙ (Плановый приём; при генерализованной форме с гнойничками — срочно)"
      none
      "глубокие кожные соскобы до капиллярной крови или трихограмма, цитология при пиодермии")

   (recommendation
      "Дерматофитоз (стригущий лишай)"
      "ЖЁЛТЫЙ (Визит в ближайшее время, ограничьте контакт с детьми и другими питомцами)"
      "ВЫСОКОЗАРАЗНЫЙ ЗООНОЗ! Возбудитель передаётся людям и животным — соблюдайте изоляцию, работайте в перчатках и дезинфицируйте помещение"
      "осмотр лампой Вуда, прямая микроскопия волос (трихограмма), микологический посев или ПЦР"))

;;;********************************************************************
;;;  Правила запуска и вывода результатов диагностики
;;;********************************************************************

;;; Правило system-banner выводит заголовок экспертной системы при запуске
(defrule system-banner ""
   (declare (salience 500))
   =>
   (printout t crlf)
   (printout t "============================================================" crlf)
   (printout t "  ЭКСПЕРТНАЯ СИСТЕМА ДИАГНОСТИКИ ЗАБОЛЕВАНИЙ СОБАК (CLIPS)  " crlf)
   (printout t "  Отвечайте на вопросы: да. или нет. (с точкой в конце)     " crlf)
   (printout t "============================================================" crlf crlf))

;;; Правило print-diagnosis выводит установленный диагноз и клинические
;;; рекомендации (срочность AAHA, зоонозность, диагностика)
(defrule print-diagnosis ""
   (declare (salience 400))
   (diagnosis ?disease)
   (recommendation ?disease ?urgency ?zoonosis ?diagnostics)
   =>
   (printout t crlf)
   (printout t "============================================================" crlf)
   (printout t "Предполагаемое заболевание: " ?disease crlf)
   (printout t "Уровень срочности (AAHA): " ?urgency crlf)
   (if (neq ?zoonosis none)
       then
       (printout t "ВНИМАНИЕ (зооноз): " ?zoonosis crlf))
   (printout t "Рекомендуемая диагностика у врача: " ?diagnostics crlf)
   (printout t "Примечание: результат является предварительным скринингом" crlf)
   (printout t "и не заменяет очный осмотр ветеринарного врача." crlf)
   (printout t "============================================================" crlf crlf))

;;; Правило print-unknown-diagnosis выводит сообщение, если заболевание
;;; не удалось определить по имеющимся правилам базы знаний
(defrule print-unknown-diagnosis ""
   (declare (salience 400))
   (diagnosis unknown)
   =>
   (printout t crlf)
   (printout t "============================================================" crlf)
   (printout t "К сожалению, по указанным симптомам заболевание определить не удалось." crlf)
   (printout t "ВАЖНО: при ухудшении состояния (отказ от воды, одышка, судороги," crlf)
   (printout t "кровотечение, резкая слабость) немедленно обратитесь к ветеринарному врачу." crlf)
   (printout t "============================================================" crlf crlf))

;;;********************************************************************
;;;  Подчинённые правила вывода: синдромы, факторы риска и признаки
;;;  (высокий приоритет 350 — выводятся сразу после ввода симптомов,
;;;   избавляя пользователя от лишних вопросов)
;;;********************************************************************

;;; Синдром: рвотный
(defrule infer-syndrome-vomiting ""
   (declare (salience 350))
   (symptom vomiting yes)
   (not (syndrome vomiting))
   =>
   (assert (syndrome vomiting)))

;;; Синдром: диарейный без рвоты и лихорадки
(defrule infer-syndrome-diarrhea-no-vomit-fever ""
   (declare (salience 350))
   (symptom vomiting no)
   (symptom diarrhea yes)
   (symptom fever no)
   (symptom bloody-foul-diarrhea no)
   (not (syndrome diarrhea-no-vomit-fever))
   =>
   (assert (syndrome diarrhea-no-vomit-fever)))

;;; Синдром: афебрильное расстройство ЖКТ (ветка А — рвота без вялости и лихорадки)
(defrule infer-syndrome-afebrile-gi-vomit ""
   (declare (salience 350))
   (syndrome vomiting)
   (symptom unproductive-retching no)
   (symptom lethargy-anorexia no)
   (symptom fever no)
   (not (syndrome afebrile-gi))
   =>
   (assert (syndrome afebrile-gi)))

;;; Синдром: афебрильное расстройство ЖКТ (ветка Б — диарея без рвоты и лихорадки)
(defrule infer-syndrome-afebrile-gi-diarrhea ""
   (declare (salience 350))
   (syndrome diarrhea-no-vomit-fever)
   (not (syndrome afebrile-gi))
   =>
   (assert (syndrome afebrile-gi)))

;;; Синдром: системная интоксикация
(defrule infer-syndrome-systemic-intoxication ""
   (declare (salience 350))
   (symptom lethargy-anorexia yes)
   (not (syndrome systemic-intoxication))
   =>
   (assert (syndrome systemic-intoxication)))

;;; Синдром: лихорадочная интоксикация
(defrule infer-syndrome-febrile-intoxication ""
   (declare (salience 350))
   (syndrome systemic-intoxication)
   (symptom fever yes)
   (not (syndrome febrile-intoxication))
   =>
   (assert (syndrome febrile-intoxication)))

;;; Синдром: респираторно-конъюнктивальный
(defrule infer-syndrome-respiratory-conjunctival ""
   (declare (salience 350))
   (symptom purulent-eye-nose-discharge yes)
   (symptom cough yes)
   (not (syndrome respiratory-conjunctival))
   =>
   (assert (syndrome respiratory-conjunctival)))

;;; Синдром: афебрильный кашель
(defrule infer-syndrome-afebrile-cough ""
   (declare (salience 350))
   (symptom cough yes)
   (symptom fever no)
   (not (syndrome afebrile-cough))
   =>
   (assert (syndrome afebrile-cough)))

;;; Синдром: дизурический
(defrule infer-syndrome-dysuric ""
   (declare (salience 350))
   (symptom pollakiuria yes)
   (symptom stranguria yes)
   (not (syndrome dysuric))
   =>
   (assert (syndrome dysuric)))

;;; Синдром: полиурия-полидипсия
(defrule infer-syndrome-polyuria-polydipsia ""
   (declare (salience 350))
   (symptom polyuria-polydipsia yes)
   (not (syndrome polyuria-polydipsia))
   =>
   (assert (syndrome polyuria-polydipsia)))

;;; Синдром: энцефалитический
(defrule infer-syndrome-encephalitic ""
   (declare (salience 350))
   (symptom behavior-change yes)
   (symptom drooling-dysphagia yes)
   (symptom progressive-paralysis yes)
   (not (syndrome encephalitic))
   =>
   (assert (syndrome encephalitic)))

;;; Синдром: кожный зуд
(defrule infer-syndrome-pruritus ""
   (declare (salience 350))
   (symptom severe-pruritus yes)
   (not (syndrome pruritus))
   =>
   (assert (syndrome pruritus)))

;;; Синдром: очаговая алопеция
(defrule infer-syndrome-focal-alopecia ""
   (declare (salience 350))
   (symptom alopecia-patches yes)
   (symptom severe-pruritus no)
   (not (syndrome focal-alopecia))
   =>
   (assert (syndrome focal-alopecia)))

;;; Фактор риска: молодой или непривитый (ветка 1 — щенок/молодая собака)
(defrule infer-risk-young ""
   (declare (salience 350))
   (symptom young-age yes)
   (not (risk-factor young-or-unvaccinated))
   =>
   (assert (risk-factor young-or-unvaccinated)))

;;; Фактор риска: молодой или непривитый (ветка 2 — не привита по графику)
(defrule infer-risk-unvaccinated ""
   (declare (salience 350))
   (symptom vaccinated no)
   (not (risk-factor young-or-unvaccinated))
   =>
   (assert (risk-factor young-or-unvaccinated)))

;;; Фактор риска: укус клеща
(defrule infer-risk-tick-bite ""
   (declare (salience 350))
   (symptom tick-bite yes)
   (not (risk-factor tick-bite))
   =>
   (assert (risk-factor tick-bite)))

;;; Признак пиометры (ветка 1 — гнойные/кровянистые выделения из петли)
(defrule infer-sign-pyometra-discharge ""
   (declare (salience 350))
   (symptom vulvar-discharge yes)
   (not (sign pyometra))
   =>
   (assert (sign pyometra)))

;;; Признак пиометры (ветка 2 — увеличение живота и рвота)
(defrule infer-sign-pyometra-closed ""
   (declare (salience 350))
   (symptom abdominal-enlargement yes)
   (symptom vomiting yes)
   (not (sign pyometra))
   =>
   (assert (sign pyometra)))

;;; Признак почечного поражения (ветка 1 — полиурия-полидипсия)
(defrule infer-sign-renal-pupd ""
   (declare (salience 350))
   (syndrome polyuria-polydipsia)
   (not (sign renal-impairment))
   =>
   (assert (sign renal-impairment)))

;;; Признак почечного поражения (ветка 2 — олигурия/анурия)
(defrule infer-sign-renal-oliguria ""
   (declare (salience 350))
   (symptom oliguria-anuria yes)
   (not (sign renal-impairment))
   =>
   (assert (sign renal-impairment)))

;;; Признак чумы (ветка 1 — миоклонус/судороги)
(defrule infer-sign-distemper-neuro ""
   (declare (salience 350))
   (symptom myoclonus-seizures yes)
   (not (sign distemper))
   =>
   (assert (sign distemper)))

;;; Признак чумы (ветка 2 — гиперкератоз подушечек лап и мочки носа)
(defrule infer-sign-distemper-hyperkeratosis ""
   (declare (salience 350))
   (symptom hyperkeratosis yes)
   (not (sign distemper))
   =>
   (assert (sign distemper)))

;;; Признак чумы (ветка 3 — диарея)
(defrule infer-sign-distemper-diarrhea ""
   (declare (salience 350))
   (symptom diarrhea yes)
   (not (sign distemper))
   =>
   (assert (sign distemper)))

;;; Признак гельминтоза (ветка 1 — фрагменты гельминтов или «езда на попе»)
(defrule infer-sign-helminthiasis-direct ""
   (declare (salience 350))
   (symptom worms-or-scooting yes)
   (not (sign helminthiasis))
   =>
   (assert (sign helminthiasis)))

;;; Признак гельминтоза (ветка 2 — потеря веса при аппетите + тусклая шерсть и вздутый живот)
(defrule infer-sign-helminthiasis-indirect ""
   (declare (salience 350))
   (symptom weight-loss-good-appetite yes)
   (symptom dull-coat-potbelly yes)
   (not (sign helminthiasis))
   =>
   (assert (sign helminthiasis)))

;;;********************************************************************
;;;  Правила постановки диагноза (20 заболеваний собак, приоритеты 320..301)
;;;  При срабатывании одного правила добавляется факт (diagnosis ...),
;;;  после чего опрос немедленно завершается и выводится результат.
;;;********************************************************************

;;; 1. Острое расширение и заворот желудка (GDV)
(defrule diagnose-gdv ""
   (declare (salience 320))
   (not (diagnosis ?))
   (syndrome vomiting)
   (symptom unproductive-retching yes)
   (symptom rapid-bloat yes)
   (symptom drooling-restlessness yes)
   =>
   (assert (diagnosis "Острое расширение и заворот желудка (GDV)")))

;;; 2. Парвовирусный энтерит
(defrule diagnose-parvovirus ""
   (declare (salience 319))
   (not (diagnosis ?))
   (syndrome vomiting)
   (syndrome febrile-intoxication)
   (symptom bloody-foul-diarrhea yes)
   (symptom purulent-eye-nose-discharge no)
   (risk-factor young-or-unvaccinated)
   =>
   (assert (diagnosis "Парвовирусный энтерит")))

;;; 3. Острый панкреатит
(defrule diagnose-pancreatitis ""
   (declare (salience 318))
   (not (diagnosis ?))
   (syndrome vomiting)
   (symptom unproductive-retching no)
   (syndrome systemic-intoxication)
   (symptom bloody-foul-diarrhea no)
   (symptom purulent-eye-nose-discharge no)
   (symptom abdominal-pain-praying yes)
   =>
   (assert (diagnosis "Острый панкреатит")))

;;; 4. Лямблиоз
(defrule diagnose-giardiasis ""
   (declare (salience 317))
   (not (diagnosis ?))
   (syndrome diarrhea-no-vomit-fever)
   (symptom pale-greasy-stool yes)
   =>
   (assert (diagnosis "Лямблиоз")))

;;; 5. Гельминтоз ЖКТ
(defrule diagnose-helminthiasis ""
   (declare (salience 316))
   (not (diagnosis ?))
   (syndrome afebrile-gi)
   (sign helminthiasis)
   =>
   (assert (diagnosis "Гельминтоз ЖКТ")))

;;; 6. Пиометра (гнойное воспаление матки)
(defrule diagnose-pyometra ""
   (declare (salience 315))
   (not (diagnosis ?))
   (syndrome systemic-intoxication)
   (symptom intact-female yes)
   (syndrome polyuria-polydipsia)
   (sign pyometra)
   =>
   (assert (diagnosis "Пиометра (гнойное воспаление матки)")))

;;; 7. Бешенство
(defrule diagnose-rabies ""
   (declare (salience 314))
   (not (diagnosis ?))
   (syndrome encephalitic)
   (symptom purulent-eye-nose-discharge no)
   =>
   (assert (diagnosis "Бешенство")))

;;; 8. Чума плотоядных
(defrule diagnose-distemper ""
   (declare (salience 313))
   (not (diagnosis ?))
   (syndrome febrile-intoxication)
   (syndrome respiratory-conjunctival)
   (sign distemper)
   =>
   (assert (diagnosis "Чума плотоядных")))

;;; 9. Лептоспироз
(defrule diagnose-leptospirosis ""
   (declare (salience 312))
   (not (diagnosis ?))
   (syndrome febrile-intoxication)
   (symptom jaundice yes)
   (sign renal-impairment)
   (symptom lumbar-pain-stiffness yes)
   =>
   (assert (diagnosis "Лептоспироз")))

;;; 10. Бабезиоз (пироплазмоз)
(defrule diagnose-babesiosis ""
   (declare (salience 311))
   (not (diagnosis ?))
   (syndrome febrile-intoxication)
   (risk-factor tick-bite)
   (symptom dark-urine yes)
   (symptom pale-gums yes)
   =>
   (assert (diagnosis "Бабезиоз (пироплазмоз)")))

;;; 11. Эрлихиоз
(defrule diagnose-ehrlichiosis ""
   (declare (salience 310))
   (not (diagnosis ?))
   (syndrome febrile-intoxication)
   (risk-factor tick-bite)
   (symptom dark-urine no)
   (symptom bleeding-petechiae yes)
   (symptom lameness-lymphadenopathy yes)
   =>
   (assert (diagnosis "Эрлихиоз")))

;;; 12. Инфекционный трахеобронхит (вольерный кашель)
(defrule diagnose-kennel-cough ""
   (declare (salience 309))
   (not (diagnosis ?))
   (syndrome afebrile-cough)
   (symptom exercise-intolerance no)
   (symptom purulent-eye-nose-discharge no)
   (symptom harsh-honking-cough yes)
   =>
   (assert (diagnosis "Инфекционный трахеобронхит (вольерный кашель)")))

;;; 13. Дирофиляриоз (сердечный гельминт)
(defrule diagnose-heartworm ""
   (declare (salience 308))
   (not (diagnosis ?))
   (syndrome afebrile-cough)
   (symptom exercise-intolerance yes)
   (symptom weight-loss-syncope yes)
   =>
   (assert (diagnosis "Дирофиляриоз (сердечный гельминт)")))

;;; 14. Острый бактериальный цистит
(defrule diagnose-cystitis ""
   (declare (salience 307))
   (not (diagnosis ?))
   (syndrome dysuric)
   (symptom hematuria-groin-licking yes)
   (symptom jaundice no)
   =>
   (assert (diagnosis "Острый бактериальный цистит")))

;;; 15. Сахарный диабет
(defrule diagnose-diabetes ""
   (declare (salience 306))
   (not (diagnosis ?))
   (syndrome polyuria-polydipsia)
   (symptom fever no)
   (symptom stranguria no)
   (symptom increased-appetite-weight-loss yes)
   =>
   (assert (diagnosis "Сахарный диабет")))

;;; 16. Наружный отит
(defrule diagnose-otitis ""
   (declare (salience 305))
   (not (diagnosis ?))
   (symptom head-shaking-ear-scratching yes)
   (symptom ear-canal-inflammation yes)
   =>
   (assert (diagnosis "Наружный отит")))

;;; 17. Саркоптоз (зудневая чесотка)
(defrule diagnose-sarcoptic-mange ""
   (declare (salience 304))
   (not (diagnosis ?))
   (syndrome pruritus)
   (symptom crusts-alopecia yes)
   (symptom sarcoptic-locations yes)
   =>
   (assert (diagnosis "Саркоптоз (зудневая чесотка)")))

;;; 18. Атопический дерматит
(defrule diagnose-atopic-dermatitis ""
   (declare (salience 303))
   (not (diagnosis ?))
   (syndrome pruritus)
   (symptom crusts-alopecia no)
   (symptom licking-paws-face yes)
   (symptom chronic-seasonal-itch yes)
   =>
   (assert (diagnosis "Атопический дерматит")))

;;; 19. Демодекоз
(defrule diagnose-demodicosis ""
   (declare (salience 302))
   (not (diagnosis ?))
   (syndrome focal-alopecia)
   (symptom round-patches-broken-hairs no)
   (symptom demodex-locations yes)
   =>
   (assert (diagnosis "Демодекоз")))

;;; 20. Дерматофитоз (стригущий лишай)
(defrule diagnose-dermatophytosis ""
   (declare (salience 301))
   (not (diagnosis ?))
   (syndrome focal-alopecia)
   (symptom round-patches-broken-hairs yes)
   (symptom scaling-crusts-on-lesions yes)
   =>
   (assert (diagnosis "Дерматофитоз (стригущий лишай)")))

;;;********************************************************************
;;;  Диагностические правила опроса пользователя (приоритеты 200..72)
;;;  Каждое правило проверяет, что диагноз ещё не поставлен и нужный
;;;  симптом ещё не выяснен, и задаёт вопрос только при выполнении
;;;  клинических предпосылок соответствующей ветви диагностики.
;;;********************************************************************

;;; --- Группа 1: GDV (Острое расширение и заворот желудка) ---

(defrule determine-vomiting ""
   (declare (salience 200))
   (not (symptom vomiting ?))
   (not (diagnosis ?))
   =>
   (ask-symptom vomiting
      "У собаки наблюдается рвота или безуспешные позывы к рвоте (да./нет.): "))

(defrule determine-unproductive-retching ""
   (declare (salience 199))
   (syndrome vomiting)
   (not (symptom unproductive-retching ?))
   (not (diagnosis ?))
   =>
   (ask-symptom unproductive-retching
      "Позывы к рвоте носят непродуктивный характер (без выхода пищи или жидкости) (да./нет.): "))

(defrule determine-rapid-bloat ""
   (declare (salience 198))
   (syndrome vomiting)
   (symptom unproductive-retching yes)
   (not (symptom rapid-bloat ?))
   (not (diagnosis ?))
   =>
   (ask-symptom rapid-bloat
      "У собаки наблюдается быстрое вздутие и напряжение живота (да./нет.): "))

(defrule determine-drooling-restlessness ""
   (declare (salience 197))
   (syndrome vomiting)
   (symptom unproductive-retching yes)
   (symptom rapid-bloat yes)
   (not (symptom drooling-restlessness ?))
   (not (diagnosis ?))
   =>
   (ask-symptom drooling-restlessness
      "У собаки наблюдается обильное слюнотечение и беспокойство (да./нет.): "))

;;; --- Группа 2: Парвовирусный энтерит ---

(defrule determine-lethargy-anorexia-vomiting ""
   (declare (salience 195))
   (syndrome vomiting)
   (not (symptom lethargy-anorexia ?))
   (not (diagnosis ?))
   =>
   (ask-symptom lethargy-anorexia
      "У собаки наблюдается выраженная вялость и отказ от корма (да./нет.): "))

(defrule determine-fever-parvo ""
   (declare (salience 194))
   (syndrome vomiting)
   (syndrome systemic-intoxication)
   (not (symptom fever ?))
   (not (diagnosis ?))
   =>
   (ask-symptom fever
      "У собаки наблюдается повышенная температура тела (выше 39.2 °C) или озноб (да./нет.): "))

(defrule determine-bloody-foul-diarrhea-parvo ""
   (declare (salience 193))
   (syndrome vomiting)
   (syndrome febrile-intoxication)
   (not (symptom bloody-foul-diarrhea ?))
   (not (diagnosis ?))
   =>
   (ask-symptom bloody-foul-diarrhea
      "У собаки наблюдается профузный кровавый понос со зловонным запахом (да./нет.): "))

(defrule determine-purulent-discharge-parvo ""
   (declare (salience 192))
   (syndrome vomiting)
   (syndrome febrile-intoxication)
   (symptom bloody-foul-diarrhea yes)
   (not (symptom purulent-eye-nose-discharge ?))
   (not (diagnosis ?))
   =>
   (ask-symptom purulent-eye-nose-discharge
      "У собаки наблюдаются гнойные выделения из глаз и носа (да./нет.): "))

(defrule determine-young-age ""
   (declare (salience 191))
   (syndrome vomiting)
   (syndrome febrile-intoxication)
   (symptom bloody-foul-diarrhea yes)
   (symptom purulent-eye-nose-discharge no)
   (not (risk-factor young-or-unvaccinated))
   (not (symptom young-age ?))
   (not (diagnosis ?))
   =>
   (ask-symptom young-age
      "Возраст собаки: щенок или молодая собака (до 1 года) (да./нет.): "))

(defrule determine-vaccinated ""
   (declare (salience 190))
   (syndrome vomiting)
   (syndrome febrile-intoxication)
   (symptom bloody-foul-diarrhea yes)
   (symptom purulent-eye-nose-discharge no)
   (symptom young-age no)
   (not (risk-factor young-or-unvaccinated))
   (not (symptom vaccinated ?))
   (not (diagnosis ?))
   =>
   (ask-symptom vaccinated
      "Собака регулярно привита по графику (да./нет.): "))

;;; --- Группа 3: Острый панкреатит ---

(defrule determine-bloody-foul-diarrhea-pancreatitis ""
   (declare (salience 189))
   (syndrome vomiting)
   (symptom unproductive-retching no)
   (syndrome systemic-intoxication)
   (not (symptom bloody-foul-diarrhea ?))
   (not (diagnosis ?))
   =>
   (ask-symptom bloody-foul-diarrhea
      "У собаки наблюдается профузный кровавый понос со зловонным запахом (да./нет.): "))

(defrule determine-purulent-discharge-pancreatitis ""
   (declare (salience 188))
   (syndrome vomiting)
   (symptom unproductive-retching no)
   (syndrome systemic-intoxication)
   (symptom bloody-foul-diarrhea no)
   (not (symptom purulent-eye-nose-discharge ?))
   (not (diagnosis ?))
   =>
   (ask-symptom purulent-eye-nose-discharge
      "У собаки наблюдаются гнойные выделения из глаз и носа (да./нет.): "))

(defrule determine-abdominal-pain-praying ""
   (declare (salience 187))
   (syndrome vomiting)
   (symptom unproductive-retching no)
   (syndrome systemic-intoxication)
   (symptom bloody-foul-diarrhea no)
   (symptom purulent-eye-nose-discharge no)
   (not (symptom abdominal-pain-praying ?))
   (not (diagnosis ?))
   =>
   (ask-symptom abdominal-pain-praying
      "У собаки наблюдается боль в животе или «поза молящейся собаки» (передние лапы вытянуты, таз приподнят) (да./нет.): "))

;;; --- Группа 4: Лямблиоз ---

(defrule determine-diarrhea-gi ""
   (declare (salience 185))
   (symptom vomiting no)
   (not (symptom diarrhea ?))
   (not (diagnosis ?))
   =>
   (ask-symptom diarrhea
      "У собаки наблюдается диарея (понос) (да./нет.): "))

(defrule determine-fever-diarrhea ""
   (declare (salience 184))
   (symptom vomiting no)
   (symptom diarrhea yes)
   (not (symptom fever ?))
   (not (diagnosis ?))
   =>
   (ask-symptom fever
      "У собаки наблюдается повышенная температура тела (выше 39.2 °C) или озноб (да./нет.): "))

(defrule determine-bloody-foul-diarrhea-gi ""
   (declare (salience 183))
   (symptom vomiting no)
   (symptom diarrhea yes)
   (symptom fever no)
   (not (symptom bloody-foul-diarrhea ?))
   (not (diagnosis ?))
   =>
   (ask-symptom bloody-foul-diarrhea
      "У собаки наблюдается профузный кровавый понос со зловонным запахом (да./нет.): "))

(defrule determine-pale-greasy-stool ""
   (declare (salience 182))
   (syndrome diarrhea-no-vomit-fever)
   (not (symptom pale-greasy-stool ?))
   (not (diagnosis ?))
   =>
   (ask-symptom pale-greasy-stool
      "Стул собаки обильный, бледный, жирный или со слизью и резким запахом (да./нет.): "))

;;; --- Группа 5: Гельминтоз ЖКТ ---

(defrule determine-fever-afebrile-gi-vomit ""
   (declare (salience 175))
   (syndrome vomiting)
   (symptom unproductive-retching no)
   (symptom lethargy-anorexia no)
   (not (symptom fever ?))
   (not (diagnosis ?))
   =>
   (ask-symptom fever
      "У собаки наблюдается повышенная температура тела (выше 39.2 °C) или озноб (да./нет.): "))

(defrule determine-worms-or-scooting ""
   (declare (salience 173))
   (syndrome afebrile-gi)
   (not (sign helminthiasis))
   (not (symptom worms-or-scooting ?))
   (not (diagnosis ?))
   =>
   (ask-symptom worms-or-scooting
      "В кале или области ануса заметны фрагменты гельминтов или перианальный зуд («езда на попе») (да./нет.): "))

(defrule determine-weight-loss-good-appetite ""
   (declare (salience 172))
   (syndrome afebrile-gi)
   (symptom worms-or-scooting no)
   (not (sign helminthiasis))
   (not (symptom weight-loss-good-appetite ?))
   (not (diagnosis ?))
   =>
   (ask-symptom weight-loss-good-appetite
      "У собаки наблюдается потеря веса при сохранённом или повышенном аппетите (да./нет.): "))

(defrule determine-dull-coat-potbelly ""
   (declare (salience 171))
   (syndrome afebrile-gi)
   (symptom worms-or-scooting no)
   (symptom weight-loss-good-appetite yes)
   (not (sign helminthiasis))
   (not (symptom dull-coat-potbelly ?))
   (not (diagnosis ?))
   =>
   (ask-symptom dull-coat-potbelly
      "У собаки наблюдаются тусклая шерсть и вздутый живот (да./нет.): "))

;;; --- Группа 6: Пиометра (гнойное воспаление матки) ---

(defrule determine-lethargy-anorexia-general ""
   (declare (salience 155))
   (not (symptom lethargy-anorexia ?))
   (not (diagnosis ?))
   =>
   (ask-symptom lethargy-anorexia
      "У собаки наблюдается выраженная вялость и отказ от корма (да./нет.): "))

(defrule determine-intact-female ""
   (declare (salience 154))
   (syndrome systemic-intoxication)
   (not (symptom intact-female ?))
   (not (diagnosis ?))
   =>
   (ask-symptom intact-female
      "Собака является нестерилизованной самкой (да./нет.): "))

(defrule determine-polyuria-polydipsia-pyometra ""
   (declare (salience 153))
   (syndrome systemic-intoxication)
   (symptom intact-female yes)
   (not (symptom polyuria-polydipsia ?))
   (not (diagnosis ?))
   =>
   (ask-symptom polyuria-polydipsia
      "У собаки наблюдается повышенная жажда и учащённое мочеиспускание (да./нет.): "))

(defrule determine-vulvar-discharge ""
   (declare (salience 152))
   (syndrome systemic-intoxication)
   (symptom intact-female yes)
   (syndrome polyuria-polydipsia)
   (not (sign pyometra))
   (not (symptom vulvar-discharge ?))
   (not (diagnosis ?))
   =>
   (ask-symptom vulvar-discharge
      "У собаки наблюдаются гнойные или кровянистые выделения из петли (да./нет.): "))

(defrule determine-abdominal-enlargement ""
   (declare (salience 151))
   (syndrome systemic-intoxication)
   (symptom intact-female yes)
   (syndrome polyuria-polydipsia)
   (symptom vulvar-discharge no)
   (symptom vomiting yes)
   (not (sign pyometra))
   (not (symptom abdominal-enlargement ?))
   (not (diagnosis ?))
   =>
   (ask-symptom abdominal-enlargement
      "У собаки наблюдается увеличение объёма живота (да./нет.): "))

;;; --- Группа 7: Бешенство ---

(defrule determine-behavior-change ""
   (declare (salience 149))
   (not (symptom behavior-change ?))
   (not (diagnosis ?))
   =>
   (ask-symptom behavior-change
      "У собаки наблюдается резкое необъяснимое изменение поведения (агрессия, пугливость или нетипичная ласковость) (да./нет.): "))

(defrule determine-drooling-dysphagia ""
   (declare (salience 148))
   (symptom behavior-change yes)
   (not (symptom drooling-dysphagia ?))
   (not (diagnosis ?))
   =>
   (ask-symptom drooling-dysphagia
      "У собаки наблюдается обильное слюнотечение или затруднённое глотание (да./нет.): "))

(defrule determine-progressive-paralysis ""
   (declare (salience 147))
   (symptom behavior-change yes)
   (symptom drooling-dysphagia yes)
   (not (symptom progressive-paralysis ?))
   (not (diagnosis ?))
   =>
   (ask-symptom progressive-paralysis
      "У собаки наблюдается прогрессирующий паралич (отвисание челюсти, шаткость, отказ лап) (да./нет.): "))

(defrule determine-purulent-discharge-rabies ""
   (declare (salience 146))
   (syndrome encephalitic)
   (not (symptom purulent-eye-nose-discharge ?))
   (not (diagnosis ?))
   =>
   (ask-symptom purulent-eye-nose-discharge
      "У собаки наблюдаются гнойные выделения из глаз и носа (да./нет.): "))

;;; --- Группа 8: Чума плотоядных ---

(defrule determine-fever-systemic ""
   (declare (salience 139))
   (syndrome systemic-intoxication)
   (not (symptom fever ?))
   (not (diagnosis ?))
   =>
   (ask-symptom fever
      "У собаки наблюдается повышенная температура тела (выше 39.2 °C) или озноб (да./нет.): "))

(defrule determine-purulent-discharge-distemper ""
   (declare (salience 138))
   (syndrome febrile-intoxication)
   (not (symptom purulent-eye-nose-discharge ?))
   (not (diagnosis ?))
   =>
   (ask-symptom purulent-eye-nose-discharge
      "У собаки наблюдаются гнойные выделения из глаз и носа (да./нет.): "))

(defrule determine-cough-distemper ""
   (declare (salience 137))
   (syndrome febrile-intoxication)
   (symptom purulent-eye-nose-discharge yes)
   (not (symptom cough ?))
   (not (diagnosis ?))
   =>
   (ask-symptom cough
      "У собаки наблюдается кашель (да./нет.): "))

(defrule determine-myoclonus-seizures ""
   (declare (salience 136))
   (syndrome febrile-intoxication)
   (syndrome respiratory-conjunctival)
   (not (sign distemper))
   (not (symptom myoclonus-seizures ?))
   (not (diagnosis ?))
   =>
   (ask-symptom myoclonus-seizures
      "У собаки наблюдаются мышечные подёргивания (нервный тик / миоклонус) или судороги (да./нет.): "))

(defrule determine-hyperkeratosis ""
   (declare (salience 135))
   (syndrome febrile-intoxication)
   (syndrome respiratory-conjunctival)
   (symptom myoclonus-seizures no)
   (not (sign distemper))
   (not (symptom hyperkeratosis ?))
   (not (diagnosis ?))
   =>
   (ask-symptom hyperkeratosis
      "У собаки наблюдается утолщение и огрубение подушечек лап и мочки носа (гиперкератоз) (да./нет.): "))

(defrule determine-diarrhea-distemper ""
   (declare (salience 134))
   (syndrome febrile-intoxication)
   (syndrome respiratory-conjunctival)
   (symptom myoclonus-seizures no)
   (symptom hyperkeratosis no)
   (not (sign distemper))
   (not (symptom diarrhea ?))
   (not (diagnosis ?))
   =>
   (ask-symptom diarrhea
      "У собаки наблюдается диарея (понос) (да./нет.): "))

;;; --- Группа 9: Лептоспироз ---

(defrule determine-jaundice-lepto ""
   (declare (salience 129))
   (syndrome febrile-intoxication)
   (not (symptom jaundice ?))
   (not (diagnosis ?))
   =>
   (ask-symptom jaundice
      "У собаки наблюдается желтушность слизистых оболочек (дёсен, белков глаз) (да./нет.): "))

(defrule determine-polyuria-polydipsia-lepto ""
   (declare (salience 128))
   (syndrome febrile-intoxication)
   (symptom jaundice yes)
   (not (sign renal-impairment))
   (not (symptom polyuria-polydipsia ?))
   (not (diagnosis ?))
   =>
   (ask-symptom polyuria-polydipsia
      "У собаки наблюдается повышенная жажда и учащённое мочеиспускание (да./нет.): "))

(defrule determine-oliguria-anuria ""
   (declare (salience 127))
   (syndrome febrile-intoxication)
   (symptom jaundice yes)
   (symptom polyuria-polydipsia no)
   (not (sign renal-impairment))
   (not (symptom oliguria-anuria ?))
   (not (diagnosis ?))
   =>
   (ask-symptom oliguria-anuria
      "У собаки наблюдается резкое уменьшение объёма мочи или прекращение мочеиспускания (да./нет.): "))

(defrule determine-lumbar-pain-stiffness ""
   (declare (salience 126))
   (syndrome febrile-intoxication)
   (symptom jaundice yes)
   (sign renal-impairment)
   (not (symptom lumbar-pain-stiffness ?))
   (not (diagnosis ?))
   =>
   (ask-symptom lumbar-pain-stiffness
      "У собаки наблюдается болезненность в области поясницы или скованность походки (да./нет.): "))

;;; --- Группы 10-11: Бабезиоз (пироплазмоз) и Эрлихиоз ---

(defrule determine-tick-bite ""
   (declare (salience 125))
   (syndrome febrile-intoxication)
   (not (symptom tick-bite ?))
   (not (diagnosis ?))
   =>
   (ask-symptom tick-bite
      "В анамнезе собаки был укус клеща или прогулка в зоне риска за последние 1-3 недели (да./нет.): "))

(defrule determine-dark-urine ""
   (declare (salience 124))
   (syndrome febrile-intoxication)
   (risk-factor tick-bite)
   (not (symptom dark-urine ?))
   (not (diagnosis ?))
   =>
   (ask-symptom dark-urine
      "У собаки наблюдается потемнение мочи (цвет «тёмного пива» или бурый) (да./нет.): "))

(defrule determine-pale-gums ""
   (declare (salience 123))
   (syndrome febrile-intoxication)
   (risk-factor tick-bite)
   (symptom dark-urine yes)
   (not (symptom pale-gums ?))
   (not (diagnosis ?))
   =>
   (ask-symptom pale-gums
      "У собаки наблюдается бледность или белизна слизистых оболочек (дёсен) (да./нет.): "))

(defrule determine-bleeding-petechiae ""
   (declare (salience 122))
   (syndrome febrile-intoxication)
   (risk-factor tick-bite)
   (symptom dark-urine no)
   (not (symptom bleeding-petechiae ?))
   (not (diagnosis ?))
   =>
   (ask-symptom bleeding-petechiae
      "У собаки наблюдается кровоточивость (точечные кровоизлияния на дёснах/коже или носовые кровотечения) (да./нет.): "))

(defrule determine-lameness-lymphadenopathy ""
   (declare (salience 121))
   (syndrome febrile-intoxication)
   (risk-factor tick-bite)
   (symptom dark-urine no)
   (symptom bleeding-petechiae yes)
   (not (symptom lameness-lymphadenopathy ?))
   (not (diagnosis ?))
   =>
   (ask-symptom lameness-lymphadenopathy
      "У собаки наблюдается скованность движений, хромота или увеличение лимфоузлов (да./нет.): "))

;;; --- Группы 12-13: Вольерный кашель и Дирофиляриоз ---

(defrule determine-cough-general ""
   (declare (salience 115))
   (not (symptom fever yes))
   (not (symptom cough ?))
   (not (diagnosis ?))
   =>
   (ask-symptom cough
      "У собаки наблюдается кашель (да./нет.): "))

(defrule determine-fever-cough ""
   (declare (salience 114))
   (symptom cough yes)
   (not (symptom fever ?))
   (not (diagnosis ?))
   =>
   (ask-symptom fever
      "У собаки наблюдается повышенная температура тела (выше 39.2 °C) или озноб (да./нет.): "))

(defrule determine-exercise-intolerance ""
   (declare (salience 113))
   (syndrome afebrile-cough)
   (not (symptom exercise-intolerance ?))
   (not (diagnosis ?))
   =>
   (ask-symptom exercise-intolerance
      "У собаки наблюдается быстрая утомляемость и одышка при физической нагрузке (да./нет.): "))

(defrule determine-purulent-discharge-kennel ""
   (declare (salience 112))
   (syndrome afebrile-cough)
   (symptom exercise-intolerance no)
   (not (symptom purulent-eye-nose-discharge ?))
   (not (diagnosis ?))
   =>
   (ask-symptom purulent-eye-nose-discharge
      "У собаки наблюдаются гнойные выделения из глаз и носа (да./нет.): "))

(defrule determine-harsh-honking-cough ""
   (declare (salience 111))
   (syndrome afebrile-cough)
   (symptom exercise-intolerance no)
   (symptom purulent-eye-nose-discharge no)
   (not (symptom harsh-honking-cough ?))
   (not (diagnosis ?))
   =>
   (ask-symptom harsh-honking-cough
      "Кашель носит сухой, грубый, лающий характер (часто с позывами к отхаркиванию) (да./нет.): "))

(defrule determine-weight-loss-syncope ""
   (declare (salience 110))
   (syndrome afebrile-cough)
   (symptom exercise-intolerance yes)
   (not (symptom weight-loss-syncope ?))
   (not (diagnosis ?))
   =>
   (ask-symptom weight-loss-syncope
      "У собаки наблюдается снижение веса или обмороки / затруднённое дыхание в покое (да./нет.): "))

;;; --- Группа 14: Острый бактериальный цистит ---

(defrule determine-pollakiuria ""
   (declare (salience 105))
   (not (symptom jaundice yes))
   (not (symptom pollakiuria ?))
   (not (diagnosis ?))
   =>
   (ask-symptom pollakiuria
      "У собаки наблюдается частое мочеиспускание малыми порциями (да./нет.): "))

(defrule determine-stranguria-cystitis ""
   (declare (salience 104))
   (symptom pollakiuria yes)
   (not (symptom jaundice yes))
   (not (symptom stranguria ?))
   (not (diagnosis ?))
   =>
   (ask-symptom stranguria
      "У собаки наблюдается болезненность или натуживание при мочеиспускании (да./нет.): "))

(defrule determine-hematuria-groin-licking ""
   (declare (salience 103))
   (syndrome dysuric)
   (not (symptom jaundice yes))
   (not (symptom hematuria-groin-licking ?))
   (not (diagnosis ?))
   =>
   (ask-symptom hematuria-groin-licking
      "У собаки наблюдается примесь крови в моче или чрезмерное вылизывание паха (да./нет.): "))

(defrule determine-jaundice-cystitis ""
   (declare (salience 102))
   (syndrome dysuric)
   (symptom hematuria-groin-licking yes)
   (not (symptom jaundice ?))
   (not (diagnosis ?))
   =>
   (ask-symptom jaundice
      "У собаки наблюдается желтушность слизистых оболочек (дёсен, белков глаз) (да./нет.): "))

;;; --- Группа 15: Сахарный диабет ---

(defrule determine-polyuria-polydipsia-diabetes ""
   (declare (salience 95))
   (not (symptom fever yes))
   (not (symptom stranguria yes))
   (not (symptom polyuria-polydipsia ?))
   (not (diagnosis ?))
   =>
   (ask-symptom polyuria-polydipsia
      "У собаки наблюдается повышенная жажда и учащённое мочеиспускание (да./нет.): "))

(defrule determine-fever-diabetes ""
   (declare (salience 94))
   (syndrome polyuria-polydipsia)
   (not (symptom stranguria yes))
   (not (symptom fever ?))
   (not (diagnosis ?))
   =>
   (ask-symptom fever
      "У собаки наблюдается повышенная температура тела (выше 39.2 °C) или озноб (да./нет.): "))

(defrule determine-stranguria-diabetes ""
   (declare (salience 93))
   (syndrome polyuria-polydipsia)
   (symptom fever no)
   (not (symptom stranguria ?))
   (not (diagnosis ?))
   =>
   (ask-symptom stranguria
      "У собаки наблюдается болезненность или натуживание при мочеиспускании (да./нет.): "))

(defrule determine-increased-appetite-weight-loss ""
   (declare (salience 92))
   (syndrome polyuria-polydipsia)
   (symptom fever no)
   (symptom stranguria no)
   (not (symptom increased-appetite-weight-loss ?))
   (not (diagnosis ?))
   =>
   (ask-symptom increased-appetite-weight-loss
      "У собаки наблюдается повышенный или нормальный аппетит при одновременной потере веса (да./нет.): "))

;;; --- Группа 16: Наружный отит ---

(defrule determine-head-shaking-ear-scratching ""
   (declare (salience 90))
   (not (symptom head-shaking-ear-scratching ?))
   (not (diagnosis ?))
   =>
   (ask-symptom head-shaking-ear-scratching
      "Собака часто трясёт головой и чешет уши (да./нет.): "))

(defrule determine-ear-canal-inflammation ""
   (declare (salience 89))
   (symptom head-shaking-ear-scratching yes)
   (not (symptom ear-canal-inflammation ?))
   (not (diagnosis ?))
   =>
   (ask-symptom ear-canal-inflammation
      "В ушном канале заметны покраснение, отёк, выделения или неприятный запах (да./нет.): "))

;;; --- Группы 17-18: Саркоптоз и Атопический дерматит ---

(defrule determine-severe-pruritus ""
   (declare (salience 85))
   (not (symptom severe-pruritus ?))
   (not (diagnosis ?))
   =>
   (ask-symptom severe-pruritus
      "У собаки наблюдается сильный, изнуряющий кожный зуд (да./нет.): "))

(defrule determine-crusts-alopecia ""
   (declare (salience 84))
   (syndrome pruritus)
   (not (symptom crusts-alopecia ?))
   (not (diagnosis ?))
   =>
   (ask-symptom crusts-alopecia
      "На коже имеются плотные желтовато-серые корки и участки облысения от расчёсов (да./нет.): "))

(defrule determine-sarcoptic-locations ""
   (declare (salience 83))
   (syndrome pruritus)
   (symptom crusts-alopecia yes)
   (not (symptom sarcoptic-locations ?))
   (not (diagnosis ?))
   =>
   (ask-symptom sarcoptic-locations
      "Поражения кожи расположены на краях ушных раковин, локтях, скакательных суставах или животе (да./нет.): "))

(defrule determine-licking-paws-face ""
   (declare (salience 82))
   (syndrome pruritus)
   (symptom crusts-alopecia no)
   (not (symptom licking-paws-face ?))
   (not (diagnosis ?))
   =>
   (ask-symptom licking-paws-face
      "Собака постоянно лижет или грызёт лапы, трёт морду и чешет подмышки или пах (да./нет.): "))

(defrule determine-chronic-seasonal-itch ""
   (declare (salience 81))
   (syndrome pruritus)
   (symptom crusts-alopecia no)
   (symptom licking-paws-face yes)
   (not (symptom chronic-seasonal-itch ?))
   (not (diagnosis ?))
   =>
   (ask-symptom chronic-seasonal-itch
      "Зуд носит хронический или сезонный характер без острых гнойных очагов (да./нет.): "))

;;; --- Группы 19-20: Демодекоз и Дерматофитоз (стригущий лишай) ---

(defrule determine-alopecia-patches ""
   (declare (salience 75))
   (symptom severe-pruritus no)
   (not (symptom alopecia-patches ?))
   (not (diagnosis ?))
   =>
   (ask-symptom alopecia-patches
      "На коже наблюдаются участки выпадения шерсти (алопеции) с покраснением, шелушением или комедонами (да./нет.): "))

(defrule determine-round-patches-broken-hairs ""
   (declare (salience 74))
   (syndrome focal-alopecia)
   (not (symptom round-patches-broken-hairs ?))
   (not (diagnosis ?))
   =>
   (ask-symptom round-patches-broken-hairs
      "Очаги облысения имеют чёткую округлую форму с обломанными у корня волосками (да./нет.): "))

(defrule determine-demodex-locations ""
   (declare (salience 73))
   (syndrome focal-alopecia)
   (symptom round-patches-broken-hairs no)
   (not (symptom demodex-locations ?))
   (not (diagnosis ?))
   =>
   (ask-symptom demodex-locations
      "Очаги выпадения шерсти расположены вокруг глаз («очки»), на морде, губах или передних лапах (либо генерализованы с гнойничками) (да./нет.): "))

(defrule determine-scaling-crusts-on-lesions ""
   (declare (salience 72))
   (syndrome focal-alopecia)
   (symptom round-patches-broken-hairs yes)
   (not (symptom scaling-crusts-on-lesions ?))
   (not (diagnosis ?))
   =>
   (ask-symptom scaling-crusts-on-lesions
      "На коже очагов присутствуют шелушение и корочки (да./нет.): "))

;;;********************************************************************
;;;  Правило завершения при невозможности постановки диагноза
;;;********************************************************************

;;; Правило no-diagnosis запускается с самым низким приоритетом (-10),
;;; если ни одно из 20 диагностических правил не смогло поставить диагноз.
(defrule no-diagnosis ""
   (declare (salience -10))
   (not (diagnosis ?))
   =>
   (assert (diagnosis unknown)))

