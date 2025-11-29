import http from "k6/http";
import { check, sleep } from "k6";

export const options = {
  vus: 50,           // 5 virtual users
  duration: "15s",  // run test 15 seconds
};

const TOKEN =
  "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJncm91cF82Iiwicm9sZSI6IlNUVURFTlQiLCJpYXQiOjE3NjQ0MDc0MDgsImV4cCI6MTc2NDQ0MzQwOH0.4cYFm9jfEwCE25e8XlhC-lc6xq0F3IbhvkkyVIixRko";

export default function () {
  const url =
    "https://ai-service-h0lx.onrender.com/api/ai/projects/68d509597520d838528cb390/ask/?q=What%20is%20summary%20of%20this%20project";

  const headers = {
    Authorization: `Bearer ${TOKEN}`,
    Accept: "application/json",
  };

  const res = http.get(url, { headers });

  check(res, {
    "status is 200": (r) => r.status === 200,
    "response time < 3s": (r) => r.timings.duration < 3000,
  });

  sleep(1);
}
