import db
import random
from flask import Flask, render_template, request, redirect, url_for, session
from datetime import datetime
from passlib.context import CryptContext


app = Flask(__name__)

password_ctx = CryptContext(schemes=['bcrypt']) 
app.secret_key = b'd2b01c987b6f7f0d5896aae06c4f318c9772d6651abff24aec19297cdf5eb199'

# Acceptation au hasard du maitre d'arme OK FAIRE UNE SESSION DE CONNEXION MA
def acceptation_ma():
    validation = [True, False]
    n_choix = random.randint(0, len(validation) - 1)
    choix = validation[n_choix]
    return choix

@app.route("/") #OK
def slash():
    return render_template("accueil.html")

@app.route("/accueil") #OK
def accueil():
    return render_template("accueil.html")


# Inscription sur le site en tant qu'adhérent
@app.route("/register", methods = ['GET', 'POST'])
def register():
    return render_template("inscription.html")

# Récupération du formulaire inscription OK
@app.route("/form_inscription",  methods=["GET", "POST"])
def process_inscr():
    form_name = request.form.get("nom")
    form_surname = request.form.get("prenom")
    form_genre = request.form.get("sexe")
    form_date_birth = request.form.get("date_de_naissance")
    form_email = request.form.get("email")
    form_mdp = request.form.get("mdp")
    form_mdp2 = request.form.get("mdp2")
    hash_pw = password_ctx.hash(form_mdp) 
    if form_mdp != form_mdp2:
        print(f"Mots de passe différents")
        return redirect(url_for("register"))
    if not form_name or not form_surname or not form_email or not form_mdp:
        print(f"Tous les champs sont obligatoires.")
        return redirect(url_for("register"))
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("insert into adherent(nom, prenom, sexe, date_de_naissance, email, hash_pw) values (%s, %s, %s, %s, %s, %s)", (form_name, form_surname, form_genre, form_date_birth, form_email, hash_pw))
            conn.commit()
    return redirect(url_for("login"))

# Page de connexion OK
@app.route("/connexion", methods=["GET", "POST"])
def login():
    return render_template("connexion.html")

# Création de la variable de session indiquant que la connexion s'est bien faite OK
@app.route("/verification", methods = ['POST'])
def connect():
    email = request.form.get("email")
    form_mdp = request.form.get("mdp")
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("select * from adherent where email = %s", (email,))
            verif_mail = cur.fetchone()
            if not verif_mail:
                return render_template("erreur_mail.html")
            cur.execute("select hash_pw from adherent where email = %s", (email,))
            mdp = cur.fetchone()
            if mdp:
                hash_pw = mdp[0]
                verif_mdp = password_ctx.verify(form_mdp, hash_pw)
                if verif_mdp:
                    session["email"] = email
                    session["n_adh"] = verif_mail[0]
                    cur.execute("select n_adh from adherent where email = %s and n_adh IN (SELECT DISTINCT n_adh from maitre_arme)", (email,))
                    n_adh_ma = cur.fetchone()
                    if not n_adh_ma:
                        return redirect(url_for("welcome"))
                    return redirect(url_for("welcome_ma"))
                return render_template("erreur_mdp.html")
    return render_template("connexion.html")

# Page d'accueil, accessible seulement si la variable de session existe OK
@app.route("/bienvenue")
def welcome():
    if "email" in session:
        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute("select nom, prenom from adherent where email = %s", (session["email"],))
                result = cur.fetchone()
                if result:
                    nom, prenom = result
                    return render_template("accueil_perso.html", nom = nom, prenom = prenom)
    return redirect(url_for("login"))

# Page d'accueil pour maitre d'armes, accessible seulement si la variable de session existe OK
@app.route("/bienvenue_ma")
def welcome_ma():
    if "email" in session:
        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute("select nom, prenom from adherent where email = %s", (session["email"],))
                result = cur.fetchone()
                if result:
                    nom, prenom = result
                    return render_template("accueil_ma.html", nom = nom, prenom = prenom)
    return redirect(url_for("login"))

# Deconnexion, suppression de la variable de session OK
@app.route("/deconnexion")
def logout():
    if "email" in session:
        session.pop("email")
    return redirect(url_for("accueil"))

# Clubs du maitre d'armes OK
@app.route("/clubs_ma")
def clubs_ma():
    n_adh = session.get("n_adh")
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("select * from club where code IN (select code from maitre_arme where n_adh = %s)", (n_adh,))
            res_club = cur.fetchall()
    return render_template("list_clubs_ma.html", listclub = res_club)

# Tournois du maitre d'armes OK
@app.route("/tournois_ma")
def tournois_ma():
    n_adh = session.get('n_adh')
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("select * from tournoi NATURAL JOIN organise where idma = %s", (n_adh,))
            res = cur.fetchall()
    return render_template("tournois_ma.html", list_tournois = res)

# Liste des clubs OK
@app.route("/clubs")
def team():
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("select * from club")
            result = cur.fetchall()
    return render_template("clubs.html", clublist = result)

# Page par club OK
@app.route("/page_club/<int:code>")
def page_club(code):
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("select * from club where code = %s", (code,))
            team = cur.fetchone()
        if not team:
            return render_template("club_error.html")
    return render_template("page_club.html", team = team)

# Formulaire de demande pour rejoindre un club en tant qu'adhérent simple ou maitre d'armes OK
@app.route("/demande")
def demand():
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("select nom from club")
            list_nom = [row[0] for row in cur.fetchall()]
    return render_template("demande.html", list_nom = list_nom)

# Traitement de demande pour joindre un club
@app.route("/process_demand_join_club", methods = ['GET','POST'])
def process_demande_club():
    form_nom_club = request.form.get("nom")
    form_lic_compet = request.form.get("lic_compet")
    form_ma = request.form.get("maitre_armes")
    n_adh = session.get("n_adh")
    if not form_nom_club or not n_adh:
        return redirect(url_for("demand"))
    try:
        with db.connect() as conn:
            with conn.cursor() as cur:
                acceptation = acceptation_ma()
                n_lic_compet = None
                cur.execute("SELECT code FROM club WHERE nom = %s;", (form_nom_club,))
                code = cur.fetchone()
                cur.execute("select * from discipline where code = %s", (code,))
                res = cur.fetchone()
                form_typearme = res[1]
                form_typestyle = res[2]
                if form_ma == "oui":
                    cur.execute("insert into maitre_arme(typearme, typetyle, n_adh) values (%s, %s, %s)", (form_typearme, form_typestyle, n_adh,))
                if form_lic_compet == "oui":
                    cur.execute("insert into licence_competition default values returning n_lic_compet;")
                    n_lic_compet = cur.fetchone()
                cur.execute("insert into licence(n_lic_compet, code) values (%s, %s) RETURNING n_licence;", (n_lic_compet, code,))
                n_licence = cur.fetchone()[0]
                cur.execute("insert into renouvellement(annee, validation_renouv, n_licence, n_adh, code) values (%s, %s, %s, %s, %s)", (datetime.now().year, acceptation, n_licence, n_adh, code))
    except:
        print(f"Erreur lors de l'insertion")
        return "Une erreur est survenue lors du traitement de la demande.", 500
    return render_template("demande_joindre_club.html", nom_club = form_nom_club)


# Création d'un club OK
@app.route("/creer_club")
def create():
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT DISTINCT typearme from discipline")
            arme = [row[0] for row in cur.fetchall()]
            cur.execute("SELECT DISTINCT typestyle from discipline")
            style = [row[0] for row in cur.fetchall()]
    return render_template("creer_club.html", armelist = arme, stylelist = style)

# Récupération des données de demande de création de club OK
@app.route("/traitement_demande_club", methods = ['GET', 'POST'])
def process_demand_club():
    nom_club = request.form.get("nom_club")
    adresse_club = request.form.get("adresse")
    desc_club = request.form.get("descriptif")
    type_arme = request.form.get("arme")
    type_style = request.form.get("style")
    n_adh = session.get('n_adh')
    with db.connect() as conn:
        with conn.cursor() as cur:
            if not nom_club:
                return redirect(url_for("create"))
            cur.execute("insert into club(nom, adresse, descriptif) values (%s, %s, %s) returning code;", (nom_club, adresse_club, desc_club,))
            id_club = cur.fetchone()[0]
            cur.execute("insert into discipline(code, typearme, typestyle) values(%s, %s, %s)",(id_club, type_arme, type_style))
            cur.execute("insert into maitre_arme(typearme, typestyle, n_adh) values (%s, %s, %s)", (type_arme, type_style, n_adh,))
    return redirect(url_for("team"))

# Liste des tournois OK
@app.route("/tournois")
def tournaments():
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("select * from tournoi")
            result = cur.fetchall()
    return render_template("tournois.html", list_tournois = result)

# Page par tournoi OK
@app.route("/page_tournoi/<int:n_tournoi>")
def page_tournoi(n_tournoi):
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("select * from tournoi where n_tournoi = %s", (n_tournoi,))
            tournament = cur.fetchone()
        if not tournament:
            return render_template("tournoi_error.html")
    return render_template("page_tournoi.html", tournament = tournament)


#Inscription à un tournoi
@app.route("/inscription-tournoi")
def form_competition():

    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("select n_tournoi from tournoi")
            list_tournoi = [row[0] for row in cur.fetchall()]
    return render_template("inscri_tournois.html", list_tournoi = list_tournoi)

# Traitment de la demande d'inscription
@app.route("/traiter_demande_insc_tournoi", methods = ['GET', 'POST'])
def process_demand_competition():
    form_n_tournoi = request.form.get("n_tournoi")
    form_lic_compet = request.form.get("lic_compet")
    form_participant = request.form.get("participant")
    form_juge = request.form.get("juge")
    form_arbitre = request.form.get("arbitre")
    form_veut_liccompet = request.form.get("veut_liccompet")
    n_adh = session.get("n_adh")
    if not form_n_tournoi or not n_adh or not form_lic_compet:
        return redirect(url_for("form_competition"))
    try:
        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute("select date from tournoi where n_tournoi = %s", (form_n_tournoi,))
                date = cur.fetchone()
                acceptation = acceptation_ma()
                cur.execute("SELECT n_licence FROM renouvellement WHERE n_adh = %s and annee = 2024", (n_adh,))
                n_lic = cur.fetchone()
                cur.execute("select n_lic_compet from licence where n_licence = %s", (n_lic))
                verif_lic_compet = cur.fetchone()
                cur.execute("select nbmax from tournoi where n_tournoi= %s", (form_n_tournoi))
                nbmax = cur.fetchone()
                cur.execute("select count(*) from participe where n_tournoi = %s", (form_n_tournoi,))
                nb_participants = cur.fetchone()
                if form_juge == "oui" and form_arbitre == "non": 
                    cur.execute("insert into juge(n_adh, n_tournoi, validation_juge) values (%s, %s, %s)", (n_adh, form_n_tournoi, acceptation,))
                if form_arbitre == "oui" and form_juge == "non":
                    cur.execute("select n_adh_arbitre from tournoi where n_tournoi = %s", (form_n_tournoi,))
                    n_adh_arbitre = cur.fetchone()
                    if not n_adh_arbitre:
                        cur.execute("UPDATE tournoi SET n_adh_arbitre = %s WHERE n_tournoi = %s;", (n_adh, form_n_tournoi))
                        return render_template("inscription_validee.html")
                if form_participant:
                    if nbmax == nb_participants:
                        print(f"Nous sommes désolés ! Il n'y a plus de places disponibles...")
                        return redirect(url_for("tournaments")) 
                    if not verif_lic_compet:
                        print(f"Erreur, il faut obligatoirement une licence compétition pour participer à un tournoi")
                        return redirect(url_for("form_competition"))
                    if form_veut_liccompet == "oui":
                        cur.execute("insert into licence_competition default values returning n_lic_compet;")
                        nouv_lic_compet = cur.fetchone()
                        cur.execute("UPDATE licence SET n_lic_compet = %s where n_adh = %s;", (nouv_lic_compet, n_adh))
                        cur.execute("insert into participe(n_lic_compet, n_tournoi) values (%s, %s)", (nouv_lic_compet, form_n_tournoi,))
                    cur.execute("insert into participe(n_lic_compet, n_tournoi) values (%s, %s)", (form_lic_compet, form_n_tournoi,))
    except:
        print(f"Erreur lors de l'insertion")
        return "Une erreur est survenue lors du traitement de la demande.", 500
    return render_template("inscription_validee.html", date = date, n_tournoi = form_n_tournoi)

#Création d'un tournoi OK
@app.route("/creer_tournoi")
def create_competition():
    n_adh = session.get("n_adh")
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT DISTINCT type_arbitrage from tournoi")
            type_arbitrage = [row[0] for row in cur.fetchall()]
            cur.execute("SELECT DISTINCT niv_protection from tournoi")
            niv_protection = [row[0] for row in cur.fetchall()]
            cur.execute("select nom from club where code IN (select code from maitre_arme where n_adh = %s)", (n_adh,))
            res_club = [row[0] for row in cur.fetchall()]
    return render_template("creer_tournoi.html", list_arbitrage = type_arbitrage, niv_protection = niv_protection, list_clubs_ma = res_club)

#Récupération des données de création d'un tournoi OK
@app.route("/traiter_demande_tournoi", methods = ['GET', 'POST'])
def process_form():
    form_nbmax = request.form.get("nbmax") 
    form_type_arb = request.form.get("type_arbitrage")
    form_prix = request.form.get("prix")
    form_frais = request.form.get("frais")
    form_niv_pro = request.form.get("niv_protection")
    form_lieu = request.form.get("lieu")
    form_date = request.form.get("date")
    form_club = request.form.get("club")
    n_adh = session.get("n_adh")
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("select n_adh from adherent where n_adh = %s and n_adh IN (SELECT DISTINCT n_adh from maitre_arme)", (n_adh, ))
            n_adh_ma = cur.fetchone()
            if not n_adh_ma:
                return render_template("condition_ma.html")
            cur.execute("select code from club where nom = %s", (form_club,))
            code_club = cur.fetchone()
            cur.execute("select typearme from discipline where code = %s", (code_club,))
            arme = cur.fetchone()
            cur.execute("insert into tournoi(nbmax, type_arbitrage, prix, frais_inscription, niv_protection, lieu, date, typearme) values (%s, %s, %s, %s, %s, %s, %s, %s)", (form_nbmax, form_type_arb, form_prix, form_frais, form_niv_pro, form_lieu, form_date, arme, ))
    return redirect(url_for("tournaments"))


if __name__ == '__main__':
    app.run(debug=True)