import streamlit as st
import numpy as np
import time

st.set_page_config(page_title="Streamlit 貪吃蛇遊戲", layout="centered")

st.title("🐍 Streamlit 貪吃蛇遊戲")

# 遊戲參數
GRID_SIZE = 20
SPEED = 0.1  # 秒

if 'snake' not in st.session_state:
    st.session_state.snake = [(5, 5)]
    st.session_state.food = (np.random.randint(0, GRID_SIZE), np.random.randint(0, GRID_SIZE))
    st.session_state.direction = (0, 1)
    st.session_state.score = 0

# 處理方向鍵
key = st.text_input("請輸入方向 (w/a/s/d):", value="", max_chars=1)
if key == 'w' and st.session_state.direction != (1, 0):
    st.session_state.direction = (-1, 0)
elif key == 's' and st.session_state.direction != (-1, 0):
    st.session_state.direction = (1, 0)
elif key == 'a' and st.session_state.direction != (0, 1):
    st.session_state.direction = (0, -1)
elif key == 'd' and st.session_state.direction != (0, -1):
    st.session_state.direction = (0, 1)

# 移動蛇頭
head_x, head_y = st.session_state.snake[0]
dx, dy = st.session_state.direction
new_head = ((head_x + dx) % GRID_SIZE, (head_y + dy) % GRID_SIZE)

# 檢查是否撞到自己
if new_head in st.session_state.snake:
    st.error(f"遊戲結束！得分：{st.session_state.score}")
    if st.button("重新開始"):
        st.session_state.snake = [(5, 5)]
        st.session_state.food = (np.random.randint(0, GRID_SIZE), np.random.randint(0, GRID_SIZE))
        st.session_state.direction = (0, 1)
        st.session_state.score = 0
    st.stop()

st.session_state.snake = [new_head] + st.session_state.snake

# 吃到食物
if new_head == st.session_state.food:
    st.session_state.score += 1
    while True:
        new_food = (np.random.randint(0, GRID_SIZE), np.random.randint(0, GRID_SIZE))
        if new_food not in st.session_state.snake:
            break
    st.session_state.food = new_food
else:
    st.session_state.snake.pop()

# 顯示遊戲
canvas = np.zeros((GRID_SIZE, GRID_SIZE, 3), dtype=np.uint8)
for (x, y) in st.session_state.snake:
    canvas[x, y] = [0, 255, 0]  # 綠色蛇身
fx, fy = st.session_state.food
canvas[fx, fy] = [255, 0, 0]  # 紅色食物

st.markdown(f"## 得分: {st.session_state.score}")
st.image(canvas, width=400)

# 自動更新
time.sleep(SPEED)

