/*
drop table notes;
drop table refresh_tokens;
drop table users;
drop table categories;
*/

create table users
(
    id serial PRIMARY KEY,
    login text UNIQUE NOT NULL, -- varchar(30)
    password_hash text NOT NULL,
	password_salt text NOT NULL,
    name text NOT NULL, -- varchar(60)
	refresh_token text
);

CREATE TABLE refresh_tokens
(
    id uuid PRIMARY KEY,
    user_id integer NOT NULL REFERENCES users(id),
    device_uid uuid NOT NULL,
    expires timestamp NOT NULL
);

create table categories
(
    id serial primary key,
    name text not null unique -- varchar(100)
);

drop table notes;
create table notes
(
    id serial primary key,
    name text not null, -- varchar(100)
    text text not null,
    category_id int not null references categories(id),
	user_id int not null references users(id),
    created_at timestamp not null, -- timestamptz
    edited_at timestamp null, -- timestamptz
	is_deleted bool not null default false
);

create or replace function note_edit()
returns trigger as $$ begin
    new.edited_at := now();
    return new;
end; $$ language plpgsql;

create trigger note_update
before update of name, text on notes
for each row
execute function note_edit();

create table notes_history
(
	created_at timestamp primary key default now(), -- timestamptz
	text text not null
);

/*

insert into categories(name) values ('Покупки');

insert into notes(name, text, category_id, created_at)
values ('Яблоко', '2 штуки', 1, now());

select * from notes;

update notes set text = '3 штуки' where id = 1;

*/