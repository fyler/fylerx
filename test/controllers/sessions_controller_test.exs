defmodule Fyler.SessionsControllerTest do
  use Fyler.ConnCase

  test "POST /api/auth" do
    user = create(:user)
    response = post conn(), "/api/auth", [email: user.email, password: "qwerty"]
    assert "token" in json_response(response, 200)
  end

  test "POST /api/auth with wrong credentials" do
    response = post conn(), "/api/auth", [email: "user@fyler.com", password: "123"]
    assert "invalid credentials" in json_response(response, 403)["errors"]
  end

  test "DELETE /api/auth" do
    user = create(:user)
    response = post conn(), "/api/auth", [email: user.email, password: "qwerty"]

    data = json_response(response, 200) 
    assert "token" in data

    response = delete api_conn(data["token"]), "/api/auth"
    assert response.status, 200

    assert_error_sent :unauthorized, fn ->
      delete conn(), "/api/auth", [token: data["token"]]
    end
  end

  test "DELETE /api/auth unauthorized" do
    assert_error_sent :unauthorized, fn ->
      delete conn(), "/api/auth"
    end
  end
end
