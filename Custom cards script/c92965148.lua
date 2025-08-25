--リミット・リバース
--Eita The Silent Ninja
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon Procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_NINJA),1,1,Synchro.NonTuner(nil),1,99,s.matfilter)
	--Treated like Insect Type
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_RACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(RACE_INSECT)
	c:RegisterEffect(e1)
	--Your Opp cannot target other cards for effects or attacks
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetCondition(s.tgcon)
	e2:SetValue(s.atlimit)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.tglimit)
	e3:SetCondition(s.tgcon)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	--Negate eff or att
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_POSITION+CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.negcon)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCode(EVENT_BE_BATTLE_TARGET)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCountLimit(1,id)
	e5:SetOperation(s.operation)
	c:RegisterEffect(e5)
end 
--Lists "Ninja" monsters
s.listed_series={SET_NINJA}
-- Can treat a "Ninja" monster as a Tuner
function s.matfilter(c,scard,sumtype,tp)
	return c:IsSetCard(SET_NINJA,scard,sumtype,tp)
end
function s.rcchk1(c,sg)
	return c:IsRace(RACE_WARRIOR) and sg:FilterCount(Card.IsRace,c,RACE_INSECT)==1
end
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
function s.tglimit(e,c)
	return c~=e:GetHandler()
end
function s.tgcon(e)
	return Duel.IsExistingMatchingCard(Card.IsPosition,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,POS_FACEDOWN_DEFENSE)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	local loc,tg=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TARGET_CARDS)
	if not tg or not tg:IsContains(c) then return false end
	return Duel.IsChainDisablable(ev) and loc~=LOCATION_DECK
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsPosition(POS_FACEDOWN_DEFENSE) end
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingTarget(Card.IsPosition,tp,LOCATION_MZONE,0,1,nil,POS_FACEDOWN_DEFENSE)	and c:IsCanTurnSet() end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local tc=Duel.SelectMatchingCard(tp,aux.AND(Card.IsFacedown,Card.IsCanChangePosition),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc then
		Duel.HintSelection(tc)
		local pos=Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK|POS_FACEUP_DEFENSE)
		Duel.ChangePosition(tc,pos)
		Duel.NegateEffect(ev)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local tc=Duel.SelectMatchingCard(tp,aux.AND(Card.IsFacedown,Card.IsCanChangePosition),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc then
		Duel.HintSelection(tc)
		local pos=Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK|POS_FACEUP_DEFENSE)
		Duel.ChangePosition(tc,pos)
		Duel.NegateAttack()
	end
end