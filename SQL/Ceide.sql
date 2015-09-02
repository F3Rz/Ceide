use ceide;


/* Tabla que almacena las cuentas de usuario */
/* varbinary length = 16*[(string_length / 16) + 1] = 144 + 6 como margen de holgura = 150 */
/* string_length = 128 (maximo permitido en el campo) */
/* user_privileges (0 = null -> no se permite) (1 = coordinador) (2 = docente) */
/* id solo puede almacenar datos de 0 - 255 */
create table accounts
(
	id_accounts
		tinyint unsigned
		not null
		auto_increment,
	
	user
		varbinary(150)
		not null,
	
	pass
		varbinary(150)
		not null,

	user_privileges
		enum(					/* Index position */ /* index 0 = null */
			'coodinador',		/* 1 */
			'teacher')			/* 2 */
		default 'teacher'
		not null,

	primary key (id_accounts),

	unique (user),

	index user_pass (user, pass)
)
AUTO_INCREMENT = 1,
DEFAULT CHAR SET = utf8,
COLLATE = utf8_unicode_ci,
ENGINE = InnoDB;


/* Tabla que almacena los datos basicos de los usuarios */
create table account_data
(
	id_account
		tinyint unsigned
		not null,

	first_name
		varchar(128)
		not null,

	last_name
		varchar(128)
		not null,
	
	primary key (id_account),
	
	constraint accdata_fk_acc
		foreign key (id_account)
		references accounts(id_accounts)
		on delete cascade
)
DEFAULT CHAR SET = utf8,
COLLATE = utf8_unicode_ci,
ENGINE = InnoDB;


/* Tabla que almacena los datos basicos de los alumnos internos */
/* Se necesita la version 5.6 (o superior) para que InnoDB soporte FULLTEXT */
create table students_int
(
	num_control
		int unsigned
		not null,

	first_name
		varchar(128)
		not null,

	last_name
		varchar(128)
		not null,

	career
		enum(								/* Index position */  /* index 0 = null */
			'Administración',				/* 1 */
			'Arquitectura',					/* 2 */
			'Electromecánica',				/* 3 */
			'Gastronomía',					/* 4 */
			'Gestión Empresarial',			/* 5 */
			'Industrial',					/* 6 */
			'Industrias Alimentarias',		/* 7 */
			'Sistemas Computacionales')		/* 8 */
		not null,

	primary key (num_control),

	fulltext fl_name (first_name, last_name),

	index car (career)
)
DEFAULT CHAR SET = utf8,
COLLATE = utf8_unicode_ci,
ENGINE = InnoDB;


/* Tabla que define los ciclos escolares */
/* Una vez establecido un registro, este no debe de poder borrarse si es que ya esta referenciado en level_,
solo se podra actualizar el valor del registro */
create table term
(
	id_term
		tinyint unsigned
		auto_increment
		not null,

	start_date
		date
		not null,

	end_date
		date
		not null,

	primary key (id_term)
)
AUTO_INCREMENT = 1,
ENGINE = InnoDB;


/* Tabla level prototipo, almacena informacion de cada nivel */
create table level_
(
	id_level
		int unsigned
		auto_increment
		not null,

	num_control
		int unsigned
		not null,

	id_term
		tinyint unsigned
		not null,

	score
		tinyint unsigned
		not null
		default 0,

	primary key (id_level),

	constraint lvl_fk_nc
		foreign key (num_control)
		references students_int(num_control)
		on delete cascade
		on update cascade,

	constraint lvl_fk_idterm
		foreign key (id_term)
		references term(id_term)
)
AUTO_INCREMENT = 1,
ENGINE = InnoDB;

/* Tablas para cada uno de los 6 niveles */
create table level_into like level_;
create table level_one like level_;
create table level_two like level_;
create table level_three like level_;
create table level_passenger_one like level_;
create table level_passenger_two like level_;

/* Cuenta de Coordinador, esta cuenta solo se deberia de crear desde codigo, no se debe de dar la opcion de crear un nuevo coordinador */
set @enc_key = 'itscc.edu.mx';

insert into accounts(user, pass, user_privileges)
	values(
		aes_encrypt('lrueda@itscc.edu.mx', @enc_key),
		aes_encrypt('ceide', @enc_key),
		1);

select
		id_accounts,
		cast(aes_decrypt(user, @enc_key) as char),
		cast(aes_decrypt(pass, @enc_key) as char),
		user_privileges
from accounts;

/* Falta tabla de certificado y posible una para historial */