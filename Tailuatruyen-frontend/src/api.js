const API_BASE = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080/api'

export async function apiRequest(path, options = {}) {
  const token = localStorage.getItem('tailuatruyen_token')
  const response = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(options.headers || {})
    }
  })

  if (!response.ok) {
    const error = await response.json().catch(() => ({}))
    throw new Error(error.message || `API error ${response.status}`)
  }
  return response.status === 204 ? null : response.json()
}

export const api = {
  stories: (page = 0, size = 12, search = '') => {
    const params = new URLSearchParams({ page, size })
    if (search) params.append('search', search)
    return apiRequest(`/stories?${params.toString()}`)
  },
  story: (id) => apiRequest(`/stories/${id}`),
  chapters: (storyId) => apiRequest(`/chapters?storyId=${storyId}&size=100`),
  chapterContent: (id) => apiRequest(`/chapters/${id}/content`),
  packages: () => apiRequest('/memberships/packages'),
  devLogin: (payload) => apiRequest('/auth/dev-login', { method: 'POST', body: JSON.stringify(payload) }),
  googleLogin: (idToken) => apiRequest('/auth/google', { method: 'POST', body: JSON.stringify({ idToken }) }),
  purchaseMembership: (packageId) => apiRequest('/memberships/purchase', { method: 'POST', body: JSON.stringify({ packageId }) }),
  membershipMe: () => apiRequest('/memberships/me'),
  topup: (amount) => apiRequest('/transactions/topup', { method: 'POST', body: JSON.stringify({ amount }) }),
  confirmTopup: (id) => apiRequest(`/transactions/${id}/confirm`, { method: 'POST' }),
  transactionStatus: (id) => apiRequest(`/transactions/${id}/status`),
  comments: (storyId, page = 0) => apiRequest(`/comments?storyId=${storyId}&page=${page}&size=20`),
  addComment: (storyId, content) => apiRequest(`/comments?storyId=${storyId}`, { method: 'POST', body: JSON.stringify({ content }) }),
  deleteComment: (id) => apiRequest(`/comments/${id}`, { method: 'DELETE' }),
  adminUsers: (page = 0) => apiRequest(`/admin/users?page=${page}&size=20`),
  toggleUserLock: (id) => apiRequest(`/admin/users/${id}/lock`, { method: 'PATCH' }),
  changeUserRole: (id, role) => apiRequest(`/admin/users/${id}/role`, { method: 'PATCH', body: JSON.stringify({ role }) }),
  adminStats: () => apiRequest('/admin/stats'),
  adminStories: () => apiRequest('/admin/stories'),
  createStory: (payload) => apiRequest('/admin/stories', { method: 'POST', body: JSON.stringify(payload) }),
  updateStory: (id, payload) => apiRequest(`/admin/stories/${id}`, { method: 'PUT', body: JSON.stringify(payload) }),
  deleteStory: (id) => apiRequest(`/admin/stories/${id}`, { method: 'DELETE' }),
  toggleStory: (id) => apiRequest(`/admin/stories/${id}/toggle`, { method: 'PATCH' }),
  restoreStory: (id) => apiRequest(`/admin/stories/${id}/restore`, { method: 'PATCH' }),
  createChapter: (storyId, payload) => apiRequest(`/admin/stories/${storyId}/chapters`, { method: 'POST', body: JSON.stringify(payload) }),
  updateChapter: (id, payload) => apiRequest(`/admin/chapters/${id}`, { method: 'PUT', body: JSON.stringify(payload) }),
  toggleChapter: (id) => apiRequest(`/admin/chapters/${id}/toggle`, { method: 'PATCH' }),
  adminTransactions: (page = 0) => apiRequest(`/admin/transactions?page=${page}&size=20`),
  crawlerSources: () => apiRequest('/crawler/sources'),
  addCrawlerSource: (payload) => apiRequest('/crawler/sources', { method: 'POST', body: JSON.stringify(payload) }),
  toggleCrawlerSource: (id) => apiRequest(`/crawler/sources/${id}/toggle`, { method: 'PATCH' }),
  runCrawler: (id) => apiRequest(id ? `/crawler/run/${id}` : '/crawler/run', { method: 'POST' }),
  crawlerLogs: () => apiRequest('/crawler/logs'),
  // Đồng bộ thông tin người dùng (số dư Silver, role) sau giao dịch mà không cần đăng nhập lại
  userMe: () => apiRequest('/users/me'),
  // Admin: lấy TẤT CẢ chapter của 1 truyện (kể cả chapter bị ẩn visible=false)
  adminChapters: (storyId) => apiRequest(`/admin/stories/${storyId}/chapters`)
}
