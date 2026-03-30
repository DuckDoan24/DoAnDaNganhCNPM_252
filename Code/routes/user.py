from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required, JWTManager, unset_jwt_cookies
from datetime import timedelta
from flask_bcrypt import Bcrypt
from db import conn

user_bp = Blueprint('user', __name__)
jwt = JWTManager()
bcrypt = Bcrypt()

@user_bp.route('/user/register', methods=['POST'])
def user_register():
    """
    Register new user
    ---
    tags:
      - User
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          properties:
            email:
              type: string
            fullname:
              type: string
            dob:
              type: string
            phonenum:
              type: string
            password:
              type: string
          required:
            - email
            - password
    responses:
      201:
        description: User created
      400:
        description: Missing fields or invalid data
    """
    data = request.get_json()

    if not data:
        return jsonify({"error": "Invalid JSON"}), 400

    email = data.get('email')
    fullname = data.get('fullname')
    dob = data.get('dob')
    phonenum = data.get('phonenum')
    password = data.get('password')

    if not email or not password:
        return jsonify({"error": "Missing required fields"}), 400

    try:
        hashed_password = bcrypt.generate_password_hash(password).decode('utf-8')

        cur = conn.cursor()
        cur.execute("""
            INSERT INTO users (email, fullname, dob, phonenum, password_hash)
            VALUES (%s, %s, %s, %s, %s)
            RETURNING id;
        """, (email, fullname, dob, phonenum, hashed_password))

        user_id = cur.fetchone()[0]
        conn.commit()

        return jsonify({
            "message": "User created",
            "id": user_id
        }), 201

    except Exception as e:
        print("error:", e)
        conn.rollback()
        return jsonify({"error": str(e)}), 400

    finally:
        cur.close()

@user_bp.route('/user/login', methods=['POST'])
def user_login():
    """
    User login
    ---
    tags:
      - User
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          properties:
            email:
              type: string
            password:
              type: string
          required:
            - email
            - password
    responses:
      200:
        description: Return JWT access token
        schema:
          type: object
          properties:
            access-token:
              type: string
      404:
        description: Wrong email or password
    """
    data = request.json
    email = data.get('email')
    password = data.get('password')

    cur = conn.cursor()
    cur.execute("""
    SELECT id, password_hash FROM users WHERE email=%s
    """, (email,))
    user = cur.fetchone()
    cur.close()
    
    if not user: return jsonify({"error": "Wrong email or password"}), 404

    user_id, user_pass = user
    if bcrypt.check_password_hash(user_pass, password):
        token = create_access_token(
            identity = user_id,
            expires_delta = timedelta(hours=1)
        )
        return jsonify({'access-token': token})
    else:
        return jsonify({"error": "Wrong email or password"})

@user_bp.route('/user/logout', methods=['POST'])
def user_logout():
    """
    User logout (clear JWT cookie)
    ---
    tags:
      - User
    responses:
      200:
        description: Logout success message
    """
    response = jsonify({"msg": "Logout successfully"})
    unset_jwt_cookies(response)
    return response

@user_bp.route('/user/<int:id>', methods=['GET'])
def user_getinfo(id):
    """
    Get user info by ID
    ---
    tags:
      - User
    parameters:
      - in: path
        name: id
        type: integer
        required: true
        description: User ID
    responses:
      200:
        description: User information
        schema:
          type: object
          properties:
            email:
              type: string
            fullname:
              type: string
            dob:
              type: string
            phonenum:
              type: string
      404:
        description: User not found
    """
    cur = conn.cursor()
    cur.execute("""
    SELECT email, fullname, dob, phonenum FROM users WHERE id=%s
    """, (id,))
    user = cur.fetchone()
    cur.close()
    if not user:
        return jsonify({"error": "User not found"}), 404
    email, fullname, dob, phonenum = user
    response = jsonify({'email':email, 'fullname':  fullname, 'dob': dob, 'phonenum': phonenum})
    return response

@user_bp.route('/user/delete/<int:id>', methods=['POST'])
def user_delete(id):
    """
    Delete user by ID
    ---
    tags:
      - User
    parameters:
      - in: path
        name: id
        type: integer
        required: true
        description: User ID to delete
    responses:
      201:
        description: User deleted successfully
      400:
        description: Delete failed
    """
    try:
        cur = conn.cursor()
        cur.execute("""
        DELETE FROM users WHERE id=%s
        """, (id,))
        conn.commit()

        return jsonify({
            "message": "User deleted",
        }), 201

    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 400

    finally:
        cur.close()

@user_bp.route('/user/update/<int:id>', methods=['POST'])
def user_update(id):
    """
    Update user profile
    ---
    tags:
      - User
    parameters:
      - in: path
        name: id
        type: integer
        required: true
        description: User ID to update
      - in: body
        name: body
        required: true
        schema:
          type: object
          properties:
            fullname:
              type: string
            dob:
              type: string
            phonenum:
              type: string
    responses:
      201:
        description: User updated successfully
      400:
        description: Update failed
    """
    data = request.json
    fullname = data.get('fullname')
    dob = data.get('dob')
    phonenum = data.get('phonenum')
    try:
        cur = conn.cursor()
        cur.execute("""
        UPDATE users
        SET fullname=%s, dob=%s, phonenum=%s
        WHERE id=%s
        """, (fullname, dob, phonenum, id))
        conn.commit()

        return jsonify({
            "message": "User updated",
        }), 201

    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 400

    finally:
        cur.close()