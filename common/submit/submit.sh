#!/usr/bin/env bash
set -euo pipefail

x() {
	(
		set -x
		"$@"
	)
}

die() {
	echo "[1;31m$1[m" >&2
	exit 1
}

yank() {
	tail -n+2 teachers.tsv | yq -p tsv \
		"$(printf 'first(.prefix == "%s").%s' "$prefix" "$1")"
}

secret="/run/secrets/user/melinda/submit"
if [ -f "$secret" ]; then
	# shellcheck disable=SC2155
	export SWAKS_OPT_auth_password="$(<"$secret")"
fi

if [ ! -v SWAKS_OPT_auth_password ]; then
	die "swaks password is not set!"
fi

cd "$HOME/org/school"

prefix="$1"
firs="$2"
last="${3-$2}"
date="$(date --iso-8601)"

name="$(yank "name")"

if [ -z "$name" ]; then
	die "invalid prefix $prefix!"
fi

if [[ "$name" =~ ^Hr. ]]; then
	anrede="Sehr geehrter"
else
	anrede="Sehr geehrte"
fi

typst compile tasks.typ

x pdfseparate tasks.pdf work-%d.pdf -f "$firs" -l "$last"
if ((firs != last)); then
	mapfile -t files < <(printf 'work-%s.pdf\n' $(seq "$firs" "$last"))
	x pdfunite "${files[@]}" workres.pdf
fi

x rm -v work-*.pdf

x swaks \
	--to "$(yank "email")" \
	--from 'melinda.stobbe@mail.de' \
	--auth-user 'melinda.stobbe@mail.de' \
	--server 'smtp.mail.de' \
	--tls-on-connect \
	--h-Subject "Aufgabenzustellung $date" \
	--attach '@workres.pdf' \
	--body - <<-EOF
		$anrede $name,

		Ich habe Ihnen die heute erledigten Aufgaben, die für Ihr Fach relevant sind,
		angefügt.
		Falls Ihnen etwas fehlt oder Sie Rückmeldungen abgeben wollen, können Sie jene
		gerne per E-Mail an mich schicken. Ich hoffe, dass meine Leistungen mindestens
		Ihren Erwartungen entsprechen.

		Falls Sie eine Drucker-freundliche (Monochrom) Variante des Aufgabenzettels
		benötigen, fragen Sie diese bitte an.

		Freundliche Grüße,

		Melinda Stobbe,
		Kurs E-Info
	EOF

notify-send --app-name="submit.sh" "Finished sending to $name."
