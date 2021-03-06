defmodule Fyler.SessionsControllerTest do
  use Fyler.ConnCase

  test "POST /auth" do
    user = create(:user)
    response = post conn(), "/auth", [email: user.email, password: "qwerty"]
    assert %{ "token" => "" <> _token } = json_response(response, 200)
  end

  test "POST /auth with wrong credentials" do
    response = post conn(), "/auth", [email: "user@fyler.com", password: "123"]
    assert %{ "errors" => "invalid_credentials" } = json_response(response, 403)
  end
end
