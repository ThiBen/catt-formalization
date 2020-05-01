{-# OPTIONS --rewriting #-}

open import Prelude
open import GSeTT.Syntax
open import GSeTT.Rules

{- PS-contexts -}
module CaTT.Ps-contexts where

  {- Rules for PS-contexts -}
  data _⊢ps_#_ : Pre-Ctx → Pre-Tm → Pre-Ty → Set where
    pss : (nil :: (O , ∗)) ⊢ps (Var O) # ∗
    psd : ∀ {Γ f A x y} → Γ ⊢ps f # (⇒ A x y) → Γ ⊢ps y # A
    pse : ∀ {Γ x A} → Γ ⊢ps x # A → ((Γ :: ((length Γ) , A)) :: (S (length Γ) , ⇒ A x (Var (length Γ)))) ⊢ps Var (S (length Γ)) # ⇒ A x (Var (length Γ))

  data _⊢ps : Pre-Ctx → Set where
    ps : ∀ {Γ x} → Γ ⊢ps x # ∗ → Γ ⊢ps


  {- PS-contexts define valid contexts -}
  Γ⊢ps→Γ⊢ : ∀ {Γ} → Γ ⊢ps → Γ ⊢C
  Γ⊢psx:A→Γ⊢x:A : ∀ {Γ x A} → Γ ⊢ps x # A → Γ ⊢t x # A

  Γ⊢ps→Γ⊢ (ps Γ⊢psx) = Γ⊢t:A→Γ⊢ (Γ⊢psx:A→Γ⊢x:A Γ⊢psx)
  Γ⊢psx:A→Γ⊢x:A pss = var (cc ec (ob ec)) (inr (idp , idp))
  Γ⊢psx:A→Γ⊢x:A (psd Γ⊢psf:x⇒y) with Γ⊢t:A→Γ⊢A (Γ⊢psx:A→Γ⊢x:A Γ⊢psf:x⇒y)
  Γ⊢psx:A→Γ⊢x:A (psd Γ⊢psf:x⇒y) | ar _ Γ⊢y:A = Γ⊢y:A
  Γ⊢psx:A→Γ⊢x:A (pse Γ⊢psx:A) with (cc (Γ⊢t:A→Γ⊢ (Γ⊢psx:A→Γ⊢x:A Γ⊢psx:A)) (Γ⊢t:A→Γ⊢A (Γ⊢psx:A→Γ⊢x:A Γ⊢psx:A)))
  ...                          | Γ,y:A⊢ = var (cc Γ,y:A⊢ (ar (wkt (Γ⊢psx:A→Γ⊢x:A Γ⊢psx:A) Γ,y:A⊢) (var Γ,y:A⊢ (inr (idp , idp))))) (inr (idp , idp))


  {- Dimension of a type and aof a context -}
  -- probably move this over to GSeTT
  dim : Pre-Ty → ℕ
  dim ∗ = O
  dim (⇒ A t u) = S (dim A)

  -- By convention, the dimension of the empty context is 0
  dimC : Pre-Ctx → ℕ
  dimC nil = O
  dimC (Γ :: (x , A)) with (dec-≤ (dim A) (dimC Γ))
  ...                         | inl _ = dimC Γ
  ...                         | inr _ = dim A

  {- Disk and sphere -}
  n-src : ℕ → ℕ
  n-tgt : ℕ → ℕ
  n⇒ : ℕ → Pre-Ty

  n-src O = O
  n-src (S n) = S (n-tgt n)
  n-tgt n = S (n-src n)

  n⇒ O = ⇒ ∗ (Var (n-src O)) (Var (n-tgt O))
  n⇒ (S n) = ⇒ (n⇒ n) (Var (n-src (S n))) (Var (n-tgt (S n)))

  𝕊 : ℕ → Pre-Ctx
  𝔻 : ℕ → Pre-Ctx

  𝕊 O = nil
  𝕊 (S n) = (𝔻 n) :: (length (𝔻 n) , n⇒ n)
  𝔻 n = (𝕊 n) :: (length (𝕊 n) , n⇒ n)


  {- source and target -}
  ∂-aux : ∀ {x A} → ℕ → (Γ : Pre-Ctx) → Γ ⊢ps x # A → Pre-Ctx
  ∂⁻-aux : ∀ {x A} → ℕ → (Γ : Pre-Ctx) → Γ ⊢ps x # A → Pre-Sub

  ∂-aux i Γ pss = Γ
  ∂-aux i Γ (psd Γ⊢psx) = ∂-aux i Γ Γ⊢psx
  ∂-aux i ((Γ :: (x , A)) :: (f , B)) (pse Γ⊢psx) with (dec-≤ i (dim A))
  ...                                             | inl _ = ∂-aux i Γ Γ⊢psx
  ...                                             | inr _  with (length (∂-aux i Γ Γ⊢psx))
  ...                                                      | n = ((∂-aux i Γ Γ⊢psx) :: (n , (A [ ∂⁻-aux i Γ Γ⊢psx ]Pre-Ty))) :: (S n , (B [ ∂⁻-aux i Γ Γ⊢psx ]Pre-Ty))
  ∂⁻-aux i Γ pss = Pre-id Γ
  ∂⁻-aux i Γ (psd Γ⊢psx) = ∂⁻-aux i Γ Γ⊢psx
  ∂⁻-aux i ((Γ :: (x , A)) :: (f , B)) (pse Γ⊢psx) with (dec-≤ i (dim A))
  ...                                             | inl _ = ∂⁻-aux i Γ Γ⊢psx
  ...                                             | inr _  with (length (∂-aux i Γ Γ⊢psx))
  ...                                                      | n = (∂⁻-aux i Γ Γ⊢psx :: (x , Var n)) :: (f , Var (S n))


  ∂i : ℕ → (Γ : Pre-Ctx) → Γ ⊢ps → Pre-Ctx
  ∂i i Γ (ps Γ⊢psx) = ∂-aux i Γ Γ⊢psx

  ∂⁻i : ℕ → (Γ : Pre-Ctx) → Γ ⊢ps → Pre-Sub
  ∂⁻i i Γ (ps Γ⊢psx) = ∂⁻-aux i Γ Γ⊢psx

  ∂ : (Γ : Pre-Ctx) → Γ ⊢ps → Γ ≠ (𝔻 O) → Pre-Ctx
  ∂ Γ Γ⊢ps  _ = ∂i (pred (dimC Γ)) Γ Γ⊢ps

  ∂⁻ : (Γ : Pre-Ctx) → Γ ⊢ps → Γ ≠ (𝔻 O) → Pre-Sub
  ∂⁻ Γ Γ⊢ps  _ = ∂⁻i (pred (dimC Γ)) Γ Γ⊢ps

  -- TODO : define target of a ps-context
